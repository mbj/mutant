# frozen_string_literal: true

module Mutant
  class Selector
    # Expression based test selector
    class Expression < self
      include Anima.new(:integration)

      # Tests for subject
      #
      # @param [Subject] subject
      #
      # @return [Enumerable<Test>]
      def call(subject)
        subject.match_expressions.each do |match_expression|
          subject_tests = integration.available_tests.select do |test|
            test.expressions.any? do |test_expression|
              match_expression.prefix?(test_expression)
            end
          end
          return subject_tests if subject_tests.any?
        end

        EMPTY_ARRAY
      end

    end # Expression
  end # Selector
end # Mutant
