# frozen_string_literal: true

require "forwardable"

module EzTemplate
  class RegexVariable
    attr_reader :regex

    extend Forwardable

    def_delegators :@regex, :match, :match?

    def initialize(regex, &block)
      raise "Block should not be nil" if block.nil?

      @regex = regex
      @block = block
    end

    def value(str, params)
      match_data = @regex.match(str)

      CleanRoom.new(params).instance_exec(match_data, &@block).to_s
    end
  end
end
