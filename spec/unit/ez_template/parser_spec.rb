# frozen_string_literal: true

module EzTemplate
  RSpec.shared_examples "normal parsing scenarios" do
    context "when the str contains several tags" do
      it "returns an array of tags" do
        tags, errors = parser.parse("{{ first_variable }} hoge huga {{ second_variable }}")

        want = [
          Tag.new("first_variable", 0, 20),
          Tag.new("second_variable", 31, 52)
        ]

        expect(tags).to eq(want)
        expect(errors).to be_empty
      end
    end

    context "when the str contains no tag" do
      it "returns an empty array" do
        tags, errors = parser.parse("There is a duck in the hallway.")

        expect(tags).to be_empty
        expect(errors).to be_empty
      end
    end

    context "when a tag string contains url" do
      it "parses as a tag correctly" do
        tags, errors = parser.parse(<<~STR)
          Please click this link : {{ https://example.com/index.html?hgoe=huga#foobar }}
        STR

        want = [Tag.new("https://example.com/index.html?hgoe=huga#foobar", 25, 78)]

        expect(tags).to eq(want)
        expect(errors).to be_empty
      end
    end

    context "when a tag contains non-ASCII characters" do
      it "parses as a tag correctly" do
        tags, errors = parser.parse(<<~STR)
          これは{{ 日本語のタグ }}です。
        STR

        want = [Tag.new("日本語のタグ", 9, 33)]

        expect(tags).to eq(want)
        expect(errors).to be_empty
      end
    end
  end

  RSpec.describe Parser do
    describe "#parse with `:ignore` on error" do
      let :parser do
        Parser.new
      end

      include_examples "normal parsing scenarios"

      context "when a tag string contains line breaks" do
        it "skips the tag" do
          tags, errors = parser.parse(<<~STR)
            There is a {{ dog_name
            }} in the {{ place }}.
          STR

          expect(tags).to eq([Tag.new("place", 33, 44)])
          expect(errors.size).to eq(1)
          e = errors[0]
          expect(e.class).to eq(InvalidCharInTagError)
          expect(e.line).to eq(1)
          expect(e.col).to eq(22)
          expect(e.char).to eq("\n")
        end
      end

      context "when a tag string contains space in the middle" do
        it "skips the tag" do
          tags, errors = parser.parse(<<~STR)
            There is a {{ dog name }} in the {{ place }}.
          STR

          expect(tags).to eq([Tag.new("place", 33, 44)])
          expect(errors.size).to eq(1)
          e = errors[0]
          expect(e.class).to eq(InvalidCharInTagError)
          expect(e.line).to eq(1)
          expect(e.col).to eq(17)
          expect(e.char).to eq(" ")
        end
      end
    end

    describe "#parse with `:fail_fast` on error" do
      let :parser do
        Parser.new({ on_error: :fail_fast })
      end

      include_examples "normal parsing scenarios"

      context "when the str contains several tags" do
        it "returns an array of tags" do
          tags, errors = parser.parse("{{ first_variable }} hoge huga {{ second_variable }}")

          want = [
            Tag.new("first_variable", 0, 20),
            Tag.new("second_variable", 31, 52)
          ]

          expect(tags).to eq(want)
          expect(errors).to be_empty
        end
      end

      context "when the str contains no tag" do
        it "returns an empty array" do
          tags, errors = parser.parse("There is a duck in the hallway.")

          expect(tags).to be_empty
          expect(errors).to be_empty
        end
      end

      context "when a tag string contains line breaks" do
        it "raise error" do
          str = <<~STR
            There is a {{ dog_name
            }}
          STR

          expect {
            parser.parse(str)
          }.to raise_error { |error|
            expect(error).to be_a(InvalidCharInTagError)
            expect(error.line).to eq(1)
            expect(error.col).to eq(22)
            expect(error.char).to eq("\n")
          }
        end
      end

      context "when a tag string contains a space in the middle" do
        it "raise error" do
          str = <<~STR
            There is a {{ dog name }}.
          STR

          expect {
            parser.parse(str)
          }.to raise_error { |error|
            expect(error).to be_a(InvalidCharInTagError)
            expect(error.line).to eq(1)
            expect(error.col).to eq(17)
            expect(error.char).to eq(" ")
          }
        end
      end
    end
  end
end
