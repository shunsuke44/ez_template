# frozen_string_literal: true

module EzTemplate
  RSpec.describe Parser do
    describe "#parse" do
      let :def_list do
        DefinitionList.new
      end

      context "with a string contains several tags" do
        it "parses the string and returns an array of tags" do
          result = Parser.parse("{{ first_variable }} hoge huga {{ second_variable }}")

          want = [
            Tag.new("first_variable", 0, 20),
            Tag.new("second_variable", 31, 52)
          ]

          expect(result).to eq(want)
        end
      end

      context "with a string contains no tag" do
        it "parses the string and returns empty array" do
          result = Parser.parse("There is a duck in the hallway.")

          expect(result).to eq([])
        end
      end

      context "when a tag contains line breaks" do
        let :str do
          <<~TEMPLATE
            There is a {{ dog_name }} in the {{place
            }}.
          TEMPLATE
        end

        it "is not recognized as tag" do
          result = Parser.parse(str)

          want = [Tag.new("dog_name", 11, 25)]

          expect(result).to eq(want)
        end
      end

      context "when a tag contains a space" do
        let :str do
          <<~TEMPLATE
            There is a {{ dog name }} in the {{ place }}.
          TEMPLATE
        end

        it "is not recognized as tag" do
          result = Parser.parse(str)

          want = [Tag.new("place", 33, 44)]
          expect(result).to eq(want)
        end
      end
    end
  end
end
