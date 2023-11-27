# frozen_string_literal: true

module Mutant
  class Expression
    class Descendants < self
      include Anima.new(:const_name)

      REGEXP = /\Adescendants:(?<const_name>.+)\z/

      def syntax
        "descendants:#{const_name}"
      end

      def matcher
        Matcher::Descendants.new(const_name: const_name)
      end
    end # Descendants
  end # Expression
end # Mutant
