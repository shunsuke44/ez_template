# frozen_string_literal: true

require "spec_helper"

module TestIntegration
  class SampleTemplate < EzTemplate::Base
    variable :animal do
      case params[:animal].to_sym
      when :dog
        "a young dog"
      when :cat
        "an old cat"
      end
    end

    variable :place

    variable(%r{https?://\w+\.com[/.\w]*$}) do |md|
      uri = URI.parse(md[0])
      "#{uri.scheme}://#{uri.host}/index.html"
    end
  end
end

module EzTemplate
  RSpec.describe EzTemplate do
    describe "#render" do
      let(:str) do
        <<~TEMPLATE
          There is {{ animal }} in the {{ place }}.

          Please visit {{ https://example.com/hogehuga/foobar.html }}
        TEMPLATE
      end

      let :template do
        ::TestIntegration::SampleTemplate.new
      end

      it "renders template with predefined variables" do
        r = template.parse(str)
        result = r.render({ animal: "dog", place: "garden" })

        expect(result).to eq(<<~EXPECT)
          There is a young dog in the garden.

          Please visit https://example.com/index.html
        EXPECT
      end
    end

    describe ".render" do
      let :str do
        <<~TEMPLATE
          There is {{ animal }} in the {{ place }}.

          Please visit {{ http://foo.com/hogehuga/bar.html }}
        TEMPLATE
      end

      let :template_class do
        ::TestIntegration::SampleTemplate
      end

      it "renders template with predefined variables" do
        r = template_class.parse(str)
        result = r.render({ animal: "cat", place: "garden" })

        expect(result).to eq(<<~EXPECT)
          There is an old cat in the garden.

          Please visit http://foo.com/index.html
        EXPECT
      end
    end
  end
end
