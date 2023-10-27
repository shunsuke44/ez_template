# frozen_string_literal: true

module EzTemplate
  RSpec.describe Parser do
    describe "#parse" do
      let :def_list do
        DefinitionList.new
      end

      context "when `:fail_fast` on error" do
        let :parser do
          Parser.new({ on_error: :fail_fast })
        end

        context "when str contains several tags" do
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

        context "when str contains no tag" do
          it "returns an empty array" do
            tags, errors = parser.parse("There is a duck in the hallway.")

            expect(tags).to be_empty
            expect(errors).to be_empty
          end
        end

        context "when a tag contains line breaks" do
          it "raise error" do
            parser.parse(<<~STR)
              There is a {{ dog_name
              }}
            STR
          rescue InvalidCharInTagError => e
            expect(e.line).to eq(1)
            expect(e.col).to eq(22)
            expect(e.char).to eq("\n")
          end
        end

        context "when tag_str contains space in the middle" do
          it "raise error" do
            parser.parse(<<~STR)
              There is a {{ dog name }}.
            STR
          rescue InvalidCharInTagError => e
            expect(e.line).to eq(1)
            expect(e.col).to eq(17)
            expect(e.char).to eq(" ")
          end
        end
      end
    end

    context "when `:ignore` on error" do
      let :parser do
        Parser.new
      end

      context "when str contains several tags" do
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

      context "when str contains no tag" do
        it "returns an empty array" do
          tags, errors = parser.parse("There is a duck in the hallway.")

          expect(tags).to be_empty
          expect(errors).to be_empty
        end
      end

      context "when a tag contains line breaks" do
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

      context "when tag_str contains space in the middle" do
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
  end
end
