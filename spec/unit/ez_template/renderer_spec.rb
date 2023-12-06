# frozen_string_literal: true

require "spec_helper"

module EzTemplate
  RSpec.shared_examples "normal rendering scenario" do
    context "when a variable definition matches the tag name" do
      it "renders a template with a context" do
        str = <<~STR
          There is a {{ animal }}.
        STR

        tags = [
          Tag.new("animal", 11, 23)
        ]

        def_list = DefinitionList.new
        def_list << Variable.new("animal") { |animal| animal }

        renderer = Renderer.new(str, tags, nil, def_list)
        result = renderer.render({ animal: :dog }, opts: opts)
        expect(result).to eq(<<~WANT)
          There is a dog.
        WANT
      end
    end
  end

  RSpec.shared_examples "rendering with `:ignore` on undefined" do
    context "when a tag name does not match any variable" do
      it "renders the tag as is" do
        str = <<~STR
          {{ hoge }}
        STR

        tags = [Tag.new("hoge", 0, 10)]

        def_list = DefinitionList.new
        def_list << Variable.new("huga") { "foobar" }

        renderer = Renderer.new(str, tags, nil, def_list)

        result = renderer.render({ "hoge": "huga" }, opts: opts)

        expect(result).to eq("{{ hoge }}\n")
      end
    end
  end

  RSpec.describe Renderer do
    describe "#render without option" do
      let :opts do
        {}
      end

      include_examples "normal rendering scenario"

      include_examples "rendering with `:ignore` on undefined"
    end

    describe "#render with `:ignore` on undefined" do
      let :opts do
        { on_undefined: :ignore }
      end

      include_examples "normal rendering scenario"

      include_examples "rendering with `:ignore` on undefined"
    end

    describe "#render with `:fail_fast` on undefined" do
      let :opts do
        { on_undefined: :fail_fast }
      end

      include_examples "normal rendering scenario"

      context "when a tag name does not match any variable" do
        it "raises error" do
          str = <<~STR
            {{ hoge }}
          STR

          tags = [Tag.new("hoge", 0, 10)]

          def_list = DefinitionList.new
          def_list << Variable.new("huga") { "foobar" }

          renderer = Renderer.new(str, tags, nil, def_list)

          begin
            renderer.render({ "hoge": "huga" }, opts: opts)
          rescue UndefinedVariable => e
            expect(e.str).to eq("hoge")
          end
        end
      end
    end

    describe "#render with `:cut_off` on undefined" do
      let :opts do
        { on_undefined: :cut_off }
      end

      include_examples "normal rendering scenario"

      context "when a tag name does not match any variable" do
        it "raises error" do
          str = <<~STR
            {{ hoge }}
          STR

          tags = [Tag.new("hoge", 0, 10)]

          def_list = DefinitionList.new
          def_list << Variable.new("huga") { "foobar" }

          renderer = Renderer.new(str, tags, nil, def_list)

          result = renderer.render({ "hoge": "huga" }, opts: opts)

          expect(result).to eq("\n")
        end
      end
    end

    describe "#render with html_escape" do
      context "when a value contains html special characters" do
        it "escapes the special characters" do
          str = <<~STR
            {{ greeting }}, {{ username }}
          STR

          tags = [Tag.new("greeting", 0, 14), Tag.new("username", 16, 30)]

          def_list = DefinitionList.new
          def_list << Variable.new("greeting") { |greeting| greeting }

          # rubocop:disable Style/SymbolProc
          def_list << Variable.new("username") { |user| user.name }
          # rubocop:enable Style/SymbolProc

          renderer = Renderer.new(str, tags, nil, def_list)

          user_class = Struct.new(:name)
          context = {
            "greeting": "<script type=\"text/javascript\">alert(1)</script>",
            "user": user_class.new(name: "<b>foobar</b>")
          }

          result = renderer.render(context, opts: { html_escape: true })

          expect(result).to eq(<<~WANT)
            &lt;script type=&quot;text/javascript&quot;&gt;alert(1)&lt;/script&gt;, &lt;b&gt;foobar&lt;/b&gt;
          WANT
        end
      end
    end

    describe "#append_variable" do
      it "appends variable" do
        str = <<~STR
          {{hoge}}
        STR

        tags = [Tag.new("hoge", 0, 8)]

        def_list = DefinitionList.new

        renderer = Renderer.new(str, tags, nil, def_list)

        renderer.append_variables(Variable.new("hoge") do
          "foobar"
        end)

        expect(renderer.render(nil)).to eq("foobar\n")
      end

      it "preserves original def_list" do
        str = <<~STR
          {{hoge}}
        STR

        tags = [Tag.new("hoge", 0, 8)]

        def_list = DefinitionList.new

        renderer = Renderer.new(str, tags, nil, def_list)

        renderer.append_variables(Variable.new("hoge") do
          "foobar"
        end)

        expect(def_list.variables.length).to eq(0)
        expect(def_list.regex_variables.length).to eq(0)
      end
    end
  end
end
