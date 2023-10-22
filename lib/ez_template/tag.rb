# frozen_string_literal: true

module EzTemplate
  # Tag represents a location to be replaced in the template string.
  class Tag
    attr_reader :str, :first, :last

    def initialize(str, first, last)
      @str = str
      @first = first
      @last = last
    end

    def ==(other)
      @str == other.str && @first == other.first && @last == other.last
    end

    def variable(def_list)
      @variable ||= def_list.get(@str)
    end
  end
end
