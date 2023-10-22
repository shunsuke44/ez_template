# frozen_string_literal: true

require "spec_helper"

module EzTemplate
  RSpec.describe RegexVariable do
    describe "#value" do
      context "with a parameter" do
        let :regex_variable do
          b = proc { |match_data, animal|
            "#{match_data[0]}'s #{animal}"
          }

          RegexVariable.new(/Alice/, b)
        end

        context "when a whole str matches regex" do
          it "calls the variable definition with match data and returns a value" do
            context = { animal: :dog }
            str = "Alice"

            val = regex_variable.value(str, context)
            expect(val).to eq("Alice's dog")
          end
        end

        context "when a part of str matches regex" do
          it "calls the variable definition with match data and returns a value" do
            context = { animal: :dog }
            str = "Alice is a college student"

            val = regex_variable.value(str, context)
            expect(val).to eq("Alice's dog")
          end
        end
      end

      context "without a parameter" do
        let :regex_variable do
          b = proc { "https://example.com" }

          RegexVariable.new(%r{\Ahttps://google.com\Z}, b)
        end

        it "calls the variable definition without match data and returns a value" do
          context = { animal: :dog }
          str = "https://google.com"

          val = regex_variable.value(str, context)

          expect(val).to eq("https://example.com")
        end
      end
    end

    describe "#required_params" do
      context "with parameters" do
        let :regex_variable do
          b = proc { |md, foo, bar|
            "#{md[0]} #{foo} #{bar}"
          }
          RegexVariable.new(/\ABob\Z/, b)
        end

        it "returns required parameters except for match data" do
          val = regex_variable.required_params

          expect(val).to eq(%i[foo bar])
        end
      end

      context "without parameters" do
        let :regex_variable do
          b = proc {}
          RegexVariable.new(/\ABob\Z/, b)
        end

        it "returns empty array" do
          expect(regex_variable.required_params).to eq([])
        end
      end

      context "with only one match data parameter" do
        let :regex_variable do
          b = proc { |md|
            md[0]
          }
          RegexVariable.new(/\Afoo\Z/, b)
        end

        it "returns empty array" do
          expect(regex_variable.required_params).to eq([])
        end
      end
    end
  end
end
