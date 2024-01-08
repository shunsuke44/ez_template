# frozen_string_literal: true

module EzTemplate
  class Variable
    attr_reader :name

    def initialize(name, &block)
      @name = name.to_s
      @block = block
    end

    def value(str, params)
      if @block.nil?
        params[@name.to_sym].to_s
      else
        CleanRoom.new(params).instance_exec(str, &@block).to_s
      end
    end
  end
end
