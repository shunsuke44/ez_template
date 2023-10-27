# frozen_string_literal: true

module EzTemplate
  # Renderer renders parsed template.
  class Renderer
    attr_reader :parse_errors

    def initialize(template, tags, errors, def_list)
      @template = template
      @tags = tags
      @parse_errors = if errors.nil?
                        []
                      else
                        errors
                      end
      @definition_list = def_list
    end

    def render(context)
      str = String.new
      cur = 0

      @tags.each do |tag|
        str << @template[cur...tag.first]
        var = tag.variable(@definition_list)
        raise "Invalid Tag : #{tag.str}" if var.nil?

        str << var.value(tag.str, context)
        cur = tag.last
      end
      str << @template[cur..]

      str
    end

    def errors
      parse_errors
    end
  end
end
