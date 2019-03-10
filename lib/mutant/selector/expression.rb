# frozen_string_literal: true

module Mutant
  class Selector
    # Expression based test selector
    class Expression < self
      include Concord.new(:integration)

      # Tests for subject
      #
      # @param [Subject] subject
      #
      # @return [Maybe<Enumerable<Test>>]
      def call(subject)
        subject.match_expressions.each do |match_expression|
          subject_tests = integration.all_tests.select do |test|
            match_expression.prefix?(test.expression)
          end

          return Maybe::Just.new(subject_tests) if subject_tests.any?
        end

        Maybe::Just.new(EMPTY_ARRAY)
      end

    end # Expression
  end # Selector
end # Mutant
