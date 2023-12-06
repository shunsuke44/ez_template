# frozen_string_literal: true

module EzTemplate
  # DefinitionList represents a list of defined template variables.
  class DefinitionList
    def initialize(vars: {}, regex_vars: [])
      @vars = vars
      @regex_vars = regex_vars
    end

    def get(var_str)
      var = @vars[var_str]
      return var unless var.nil?

      longest_match(var_str)
    end

    def <<(var)
      case var
      when Variable
        add_variable(var)
      when RegexVariable
        add_regex_variable(var)
      else
        raise "Invalid type of variable added"
      end
    end

    def add_variable(var)
      @vars[var.name] = var
    end

    def add_regex_variable(var)
      @regex_vars << var
    end

    def variables
      @vars.values
    end

    def regex_variables
      @regex_vars.clone
    end

    def clone
      new_vars = @vars.clone
      new_regex_vars = @regex_vars.clone

      DefinitionList.new(vars: new_vars, regex_vars: new_regex_vars)
    end

    private

    def longest_match(var_str)
      return nil if @regex_vars.empty?

      match_lens = @regex_vars.map do |var|
        m = var.match(var_str)
        m.nil? ? -1 : m[0].length
      end

      max = match_lens.max

      max != -1 ? @regex_vars[match_lens.index(max)] : nil
    end
  end
end
