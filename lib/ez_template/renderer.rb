# frozen_string_literal: true

require "cgi"

module EzTemplate
  class UndefinedVariable < StandardError
    attr_reader :str

    def initialize(str:)
      @str = str
      super("undefined variable: #{str}")
    end
  end

  # Renderer renders parsed template.
  # Available options are:
  #   on_undefined: When `:fail_fast`, Renderer raises UndefinedVariable error.
  #                 When `:ignore`, Renderer renders the tag as it is.
  #                 When `:cut_off`, Renderer replaces the tag with blank.
  #                 default to `:ignore`
  #   html_escape:  When true, Renderer escapes each value returned by variable definition.
  #                 When false, it doesn't.
  class Renderer
    ON_UNDEFINED_OPTS = %i[fail_fast ignore cut_off].freeze
    attr_reader :parse_errors, :tags

    def initialize(template, tags, errors, def_list, opts: {})
      @template = template
      @tags = tags
      @parse_errors = if errors.nil?
                        []
                      else
                        errors
                      end
      @is_original_definition_list = true
      @definition_list = def_list
      @opts = opts
    end

    def render(params, opts: {})
      str = String.new
      cur = 0

      @tags.each do |tag|
        str << @template[cur...tag.first]
        var = tag.variable(@definition_list)
        if var.nil?
          case on_undefined(opts)
          when :fail_fast
            raise UndefinedVariable.new(str: tag.str)
          when :cut_off
            cur = tag.last
            next
          else
            next
          end
        end

        str << if html_escape?(opts)
                 CGI.escapeHTML(var.value(tag.str, params))
               else
                 var.value(tag.str, params)
               end
        cur = tag.last
      end
      str << @template[cur..]

      str
    end

    def render_html(params, opts: {})
      opts[:html_escape] = true
      render(params, opts: opts)
    end

    def errors
      parse_errors
    end

    def render_opts=(opts)
      @opts = opts
    end

    def append_variables(*args)
      # Copy DefinitionList on write
      if @is_original_definition_list
        @is_original_definition_list = false
        @definition_list = @definition_list.clone
      end

      args.each do |var|
        @definition_list << var
      end
    end

    private

    def html_escape?(opts)
      return opts[:html_escape] unless opts[:html_escape].nil?

      @opts[:html_escape]
    end

    def on_undefined(opts)
      on_undefined = opts[:on_undefined]&.to_sym
      return on_undefined if ON_UNDEFINED_OPTS.include? on_undefined

      on_undefined = @opts[:on_undefined]&.to_sym
      return on_undefined if ON_UNDEFINED_OPTS.include? on_undefined

      :ignore
    end
  end
end
