# frozen_string_literal: true

module EzTemplate
  RSpec.describe Variable do
    describe "#value" do
      context "with block" do
        let :variable do
          Variable.new(:hoge) do
            if params[:user] == :alice
              case params[:animal]
              when :dog
                "dog"
              when :cat
                "cat"
              end
            else
              "bob"
            end
          end
        end

        it "calls variable definition block and returns value" do
          params = { user: :alice, animal: :dog }
          result = variable.value("hoge", params)

          expect(result).to eq("dog")
        end
      end

      context "without block" do
        let :variable do
          Variable.new(:hoge)
        end

        it "returns context value directly" do
          params = { hoge: "huga" }

          result = variable.value("hoge", params)
          expect(result).to eq("huga")
        end
      end

      context "with no matching context value" do
        let :variable do
          Variable.new(:hoge) do
            case params[:animal]
            when nil
              "nil value"
            end
          end
        end

        it "passes nil to the variable callback" do
          params = {}

          expect(variable.value("hoge", params)).to eq("nil value")
        end
      end
    end
  end
end
