# frozen_string_literal: true

require "strscan"

module EzTemplate
  # ParseError represents an error on parse.
  #
  # @attr_reader line 1-based-indexed line number where the error occurred.
  # @attr_reader col 1-based-indexed column number where the error occurred.
  class ParseError < StandardError
    attr_reader :line, :col

    def initialize(msg = "Failed to parse template", line: nil, col: nil)
      @line = line
      @col = col
      super(msg)
    end
  end

  class NoMatchingTagError < ParseError
    def initialize(msg = "No matching tag", line: nil, col: nil)
      super
    end
  end

  class InvalidCharInTagError < ParseError
    attr_reader :char

    def initialize(msg = "Invalid character in tag", line: nil, col: nil, char: nil)
      @char = char
      super(msg, line: line, col: col)
    end
  end

  # Parser parses a template string.
  # Available options are:
  #   on_error: When `:fail_fast`, Parser raises an exception on parse error.
  #             When `:ignore`, Parser ignores the error and continues parsing.
  #             default to `:ignore`.
  class Parser
    attr_reader :tags, :errors

    def initialize(opts = {})
      @opts = opts
    end

    # Given a string and a definition list, returns an array of tags.
    def parse(str)
      @linenum = 1
      @pos_offset = 0
      @tags = []
      @errors = []

      str.lines.each.with_index(1) do |line, linenum|
        @linenum = linenum
        parse_line(line)
        @pos_offset += line.size
      end

      [@tags, @errors]
    end

    def self.parse(str)
      new.parse(str)
    end

    def self.parse!(str)
      new({ on_error: :fail_fast }).parse(str)
    end

    private

    def fail_fast?
      @opts[:on_error]&.to_sym == :fail_fast
    end

    def parse_line(line)
      scanner = StringScanner.new(line)

      while parse_tag(scanner); end
    end

    def parse_tag(scanner)
      str = scanner.scan_until(/{{+/)
      return false if str.nil?

      inner_tag(scanner, scanner.pos - 2)
    end

    def inner_tag(scanner, first)
      scanner.scan(/\s+/)
      tag_str = scanner.scan(/[[:print:]&&[^\s{}]]+/)
      if tag_str.nil?
        raise InvalidCharInTagError.new(line: @linenum, col: scanner.pos, char: scanner.rest[0]) if fail_fast?

        @errors << InvalidCharInTagError.new(line: @linenum, col: scanner.pos, char: scanner.rest[0])
        return true
      end

      closing_tag = scanner.scan(/\s*}}/)

      if closing_tag.nil?
        raise InvalidCharInTagError.new(line: @linenum, col: scanner.pos, char: scanner.rest[0]) if fail_fast?

        @errors << InvalidCharInTagError.new(
          line: @linenum, col: scanner.pos, char: scanner.rest[0]
        ) # 1-based index
        return true
      end

      @tags << Tag.new(tag_str, first + @pos_offset, scanner.pos + @pos_offset)
      true
    end
  end
end
