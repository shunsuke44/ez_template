# frozen_string_literal: true

require "forwardable"

module EzTemplate
  class RegexVariable
    attr_reader :regex

    extend Forwardable

    def_delegators :@regex, :match, :match?

    def initialize(regex, block)
      raise "Block should not be nil" if block.nil?

      @regex = regex
      @block = block
    end

    def value(str, context)
      match_data = @regex.match(str)

      args, kwargs = build_args(match_data, context)
      @block.call(*args, **kwargs).to_s
    end

    def required_params
      p = @block.parameters[1..]&.map { |v| v[1] }
      p.nil? ? [] : p
    end

    private

    def build_args(match_data, context)
      parameters = @block.parameters
      return [], {} if parameters.empty?

      args = [match_data]
      kwargs = {}
      @block.parameters[1..].each do |param|
        type = param[0]
        name = param[1]
        case type
        when :req, :opt
          args << context[name]
        when :keyreq, :key
          kwargs[name] = context[name]
        end
      end
      [args, kwargs]
    end
  end
end
