# frozen_string_literal: true

module Mutant
  class Integration
    # Null integration that has no tests
    class Null < self
      # Available tests for integration
      #
      # @return [Enumerable<Test>]
      def all_tests = EMPTY_ARRAY

      # Run a collection of tests
      #
      # @param [Enumerable<Mutant::Test>] tests
      #
      # @return [Result::Test]
      def call(_tests)
        Result::Test.new(
          job_index: nil,
          output:    '',
          passed:    true,
          runtime:   0.0
        )
      end

    end # Null
  end # Integration
end # Mutant
