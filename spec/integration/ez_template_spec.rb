# frozen_string_literal: true

require "spec_helper"

module TestIntegration
  class SampleTemplate < EzTemplate::Base
    variable :animal
    variable :place
    variable(/action/) do |_md, animal|
      case animal.to_sym
      when :dog
        "running"
      when :cat
        "smiling"
      end
    end
  end
end

module EzTemplate
  RSpec.describe EzTemplate do
    describe "#render" do
      let(:str) do
        <<~TEMPLATE
          There is a {{ animal }} in the {{ place }}.
          It is {{ action }}.
        TEMPLATE
      end

      let :template do
        ::TestIntegration::SampleTemplate.new
      end

      it "renders template with predefined variables" do
        r = template.parse(str)
        result = r.render({ animal: "dog", place: "garden" })

        expect(result).to eq(<<~EXPECT)
          There is a dog in the garden.
          It is running.
        EXPECT
      end
    end

    describe ".render" do
      let :str do
        <<~TEMPLATE
          There is a {{ animal }} in the {{ place }}.
          It is {{ action }}.
        TEMPLATE
      end

      let :template_class do
        ::TestIntegration::SampleTemplate
      end

      it "renders template with predefined variables" do
        r = template_class.parse(str)
        result = r.render({ animal: "dog", place: "garden" })

        expect(result).to eq(<<~EXPECT)
          There is a dog in the garden.
          It is running.
        EXPECT
      end
    end
  end
end
