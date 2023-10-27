# frozen_string_literal: true

require "forwardable"

module EzTemplate
  class Base
    def parse(template, opts = {})
      tags = Parser.new(opts).parse(template)
      Renderer.new(template, tags, self.class.definition_list)
    end

    class << self
      attr_reader :definition_list

      extend Forwardable

      def_delegators :@definition_list, :variables, :regex_variables

      def inherited(base)
        super
        base.instance_variable_set :@definition_list, DefinitionList.new
      end

      def variable(name, &block)
        if name.is_a? Regexp
          raise "block is required for regex variable" if block.nil?

          definition_list << RegexVariable.new(name, block)
        else
          definition_list << Variable.new(name, block)
        end
      end

      def parse(template)
        new.parse(template)
      end
    end
  end
end
