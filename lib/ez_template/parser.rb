# frozen_string_literal: true

module EzTemplate
  module Parser
    VARIABLE_REGEX = /\{\{ ?(?<str>[^\s{}]+) ?\}\}/.freeze

    module_function

    # Given a string and a definition list, returns an array of tags.
    def parse(str)
      tags = []
      cur = 0

      loop do
        md = VARIABLE_REGEX.match(str)
        break if md.nil?

        first = md.begin(0) + cur
        last = md.end(0) + cur
        cur += md.end(0)
        str = md[:str]
        tags << Tag.new(str, first, last)

        str = md.post_match
      end

      tags
    end
  end
end
