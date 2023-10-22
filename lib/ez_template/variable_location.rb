# frozen_string_literal: true

module EzTemplate
  class VariableLocation
    attr_reader :name, :first, :last

    def initialize(name:, first:, last:, var: nil)
      @name = name
      @first = first
      @last = last
      @var = var
    end

    def ==(other)
      @name == other.name && @first == other.first && @last == other.last
    end
  end
end
