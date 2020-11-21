# frozen_string_literal: true

module Mutant
  class Integration
    # Null integration that has no tests
    class Null < self
      # Available tests for integration
      #
      # @return [Enumerable<Test>]
      def all_tests
        EMPTY_ARRAY
      end

      # Run a collection of tests
      #
      # @param [Enumerable<Mutant::Test>] tests
      #
      # @return [Result::Test]
      def call(tests)
        Result::Test.new(
          passed:  true,
          runtime: 0.0,
          tests:   tests
        )
      end

    end # Null
  end # Integration
end # Mutant
