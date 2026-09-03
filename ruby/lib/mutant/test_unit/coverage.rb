# frozen_string_literal: true

require 'test/unit'

module Mutant
  module TestUnit
    module Coverage
      # Setup coverage declaration for current class
      #
      # @param [String] expression
      #
      # @example
      #
      #   class MyTest < Test::Unit::TestCase
      #     cover 'MyCode*'
      #
      #     def test_some_stuff
      #     end
      #   end
      #
      # @api public
      def cover(expression)
        @cover_expressions = Set.new unless defined?(@cover_expressions)

        @cover_expressions << expression
      end

      # Effective coverage expression
      #
      # @return [Set<String>]
      #
      # @api private
      def resolve_cover_expressions
        return @cover_expressions if defined?(@cover_expressions)

        try_superclass_cover_expressions
      end

    private

      def try_superclass_cover_expressions
        return if superclass.equal?(::Test::Unit::TestCase) || !superclass.respond_to?(:resolve_cover_expressions)

        superclass.resolve_cover_expressions
      end

    end # Coverage
  end # TestUnit
end # Mutant

Test::Unit::TestCase.extend(Mutant::TestUnit::Coverage)
