# frozen_string_literal: true

require "spec_helper"

module EzTemplate
  RSpec.describe RegexVariable do
    describe "#value" do
      context "with a parameter" do
        let :regex_variable do
          RegexVariable.new(/Alice/) do |match_data|
            "#{match_data[0]}'s #{params[:animal]}"
          end
        end

        context "when a whole str matches regex" do
          it "calls the variable definition with match data and returns a value" do
            params = { animal: :dog }
            str = "Alice"

            val = regex_variable.value(str, params)
            expect(val).to eq("Alice's dog")
          end
        end

        context "when a part of str matches regex" do
          it "calls the variable definition with match data and returns a value" do
            params = { animal: :dog }
            str = "Alice is a college student"

            val = regex_variable.value(str, params)
            expect(val).to eq("Alice's dog")
          end
        end
      end

      context "without a parameter" do
        let :regex_variable do
          RegexVariable.new(%r{\Ahttps://google.com\Z}) do
            "https://example.com"
          end
        end

        it "calls the variable definition without match data and returns a value" do
          params = { animal: :dog }
          str = "https://google.com"

          val = regex_variable.value(str, params)

          expect(val).to eq("https://example.com")
        end
      end
    end
  end
end
