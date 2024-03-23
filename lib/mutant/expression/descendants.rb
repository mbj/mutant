# frozen_string_literal: true

module Mutant
  class Expression
    class Descendants < self
      include Anima.new(:const_name)

      REGEXP = /\Adescendants:(?<const_name>.+)\z/

      def syntax
        "descendants:#{const_name}"
      end

      # rubocop:disable Lint/UnusedMethodArgument
      def matcher(env:)
        Matcher::Descendants.new(const_name: const_name)
      end
    end # Descendants
  end # Expression
end # Mutant
