# frozen_string_literal: true

module EzTemplate
  RSpec.describe Variable do
    describe "#required_params" do
      context "with block" do
        let :variable do
          block = proc { |user, animal|
            if user == "alice"
              case animal
              when :dog
                "dog"
              when :cat
                "cat"
              end
            else
              "bob"
            end
          }

          Variable.new(:hoge, block)
        end

        it "returns parameters required to construct the variable" do
          expect(variable.required_params).to include :user, :animal
        end
      end

      context "without block" do
        let :variable do
          Variable.new(:hoge)
        end

        it "returns variable name directly" do
          expect(variable.required_params).to include :hoge
        end
      end
    end

    describe "#value" do
      context "with block" do
        let :variable do
          block = proc { |user, animal|
            if user == :alice
              case animal
              when :dog
                "dog"
              when :cat
                "cat"
              end
            else
              "bob"
            end
          }

          Variable.new(:hoge, block)
        end

        it "calls variable definition block and returns value" do
          context = { user: :alice, animal: :dog }
          result = variable.value("hoge", context)

          expect(result).to eq("dog")
        end
      end

      context "without block" do
        let :variable do
          Variable.new(:hoge)
        end

        it "returns context value directly" do
          context = { hoge: "huga" }

          result = variable.value("hoge", context)
          expect(result).to eq("huga")
        end
      end

      context "with no matching context value" do
        let :variable do
          block = proc { |animal|
            case animal
            when nil
              "nil value"
            end
          }
          Variable.new(:hoge, block)
        end

        it "passes nil to the variable callback" do
          context = {}

          expect(variable.value("hoge", context)).to eq("nil value")
        end
      end
    end
  end
end
