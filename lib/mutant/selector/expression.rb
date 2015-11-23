module Mutant
  class Selector
    # Expression based test selector
    class Expression < self
      include Concord.new(:integration)

      # Tests for subject
      #
      # @param [Subject] subject
      #
      # @return [Enumerable<Test>]
      def call(subject)
        subject.match_expressions.each do |match_expression|
          subject_tests = integration.all_tests.select do |test|
            match_expression.prefix?(test.expression)
          end
          return subject_tests if subject_tests.any?
        end

        EMPTY_ARRAY
      end

    end # Expression
  end # Selector
end # Mutant
