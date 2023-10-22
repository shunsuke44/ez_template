# frozen_string_literal: true

module EzTemplate
  class Variable
    attr_reader :name

    def initialize(name, block = nil)
      @name = name.to_s
      @block = block
    end

    def value(_str, context)
      if @block.nil?
        context[@name.to_sym].to_s
      else
        args, kwargs = build_args(context)
        @block.call(*args, **kwargs).to_s
      end
    end

    def required_params
      return [@name.to_sym] if @block.nil?

      @block.parameters.map { |v| v[1] }
    end

    private

    def build_args(context)
      args = []
      kwargs = {}
      @block.parameters.each do |param|
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
