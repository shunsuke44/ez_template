# frozen_string_literal: true

require "spec_helper"

module EzTemplate
  RSpec.describe DefinitionList do
    describe "#get" do
      let :definition_list do
        DefinitionList.new
      end

      before do
        definition_list << Variable.new("animal", proc { "dog" })
        definition_list << Variable.new("hoge", proc { "huga" })

        definition_list << RegexVariable.new(/ani.../, proc { "cat" })
        definition_list << RegexVariable.new(/foo/, proc { "bar" })
        definition_list << RegexVariable.new(/foobar/, proc { "hugahuga" })
      end

      context "when it matches variable and regex variable" do
        it "returns variable" do
          result = definition_list.get("animal")

          expect(result.class).to be(Variable)
          expect(result.name).to be("animal")
        end
      end

      context "when it matches a variable" do
        it "returns the variable" do
          result = definition_list.get("hoge")

          expect(result.class).to be(Variable)
          expect(result.name).to be("hoge")
        end
      end

      context "when it matches a regex variable" do
        it "returns the regex variable" do
          result = definition_list.get("anifoo")

          expect(result.class).to be(RegexVariable)
          expect(result.regex).to eq(/ani.../)
        end
      end

      context "when it matches several regex variables" do
        it "returns one of them with the longest match" do
          result = definition_list.get("foobar")

          expect(result.class).to be(RegexVariable)
          expect(result.regex).to eq(/foobar/)
        end
      end

      context "when there are no match" do
        it "returns nil" do
          result = definition_list.get("dog")

          expect(result).to be_nil
        end
      end

      context "when definition list has no variable" do
        it "returns nil" do
          result = DefinitionList.new.get("hoge")

          expect(result).to be_nil
        end
      end
    end
  end
end
