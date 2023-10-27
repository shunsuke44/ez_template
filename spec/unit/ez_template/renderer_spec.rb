# frozen_string_literal: true

require "spec_helper"

module EzTemplate
  RSpec.describe Renderer do
    let :template do
      <<~TEMPLATE
        There is a {{ animal }} in the {{ place }}.
        It is {{ behavior }} with {{ tool }}.
      TEMPLATE
    end

    let :tags do
      [
        Tag.new("animal", 11, 23),
        Tag.new("place", 31, 42), # 44
        Tag.new("behavior", 50, 64),
        Tag.new("tool", 70, 80)
      ]
    end

    let :def_list do
      def_list = DefinitionList.new
      def_list << Variable.new("animal", proc { "dog" })
      def_list << Variable.new("place", proc { "garden" })
      def_list << RegexVariable.new(/behavior/, proc { "playing" })
      def_list << RegexVariable.new(/tool/, proc do |_md, user|
        case user
        when "Alice" then "a ball"
        when "Bob" then "a bottle"
        end
      end)
      def_list
    end

    context "with Alice" do
      it "renders the template with the definition list" do
        renderer = Renderer.new(template, tags, nil, def_list)

        result = renderer.render({ user: "Alice" })

        expect(result).to eq(<<~WANT)
          There is a dog in the garden.
          It is playing with a ball.
        WANT
      end
    end

    context "with Bob" do
      it "renders the template with the definition list" do
        renderer = Renderer.new(template, tags, nil, def_list)

        result = renderer.render({ user: "Bob" })

        expect(result).to eq(<<~WANT)
          There is a dog in the garden.
          It is playing with a bottle.
        WANT
      end
    end
  end
end
