# frozen_string_literal: true

module Mutant
  class Selector
    # Test selector backed by a per test coverage recording
    #
    # Selects the tests that executed the subject's own source lines, which
    # finds the tests that cover a subject regardless of where they live or how
    # they are named. Subjects the recording says nothing about fall back to the
    # expression selector: code that only runs while the suite loads (a constant
    # body, a class level DSL call) executes under no test, and reporting its
    # mutations alive without running a single test would be a lie.
    class ContextMap < self
      include Anima.new(:context_map, :fallback, :integration)

      # Name of the strategy this selector implements
      #
      # @return [String]
      def name = 'context_map'

      # Tests for subject, likeliest killer first
      #
      # @param [Subject] subject
      #
      # @return [Enumerable<Test>]
      def call(subject)
        reach = context_map.reach(path: subject.source_path, lines: subject.source_lines)

        covering = reach.flat_map do |location, lines|
          index.fetch(location, EMPTY_ARRAY).map { |test| [test, lines, context_map.footprint(location)] }
        end

        return fallback.call(subject) if covering.empty?

        order(covering, subject)
      end

      # Whether the recording names no test this suite runs
      #
      # A recording taken from another project root, or from a suite that has
      # since been renamed away, covers everything and matches nothing. Left
      # unsaid it looks exactly like a suite in which no test covers anything.
      #
      # @return [Boolean]
      def unmatched?
        index.each_key.none? { |location| context_map.context_ids.include?(location) }
      end

    private

      # A run against a mutation stops at the first failing test, so this order
      # is the difference between running one test and running all of them.
      #
      # A test the expressions would also have picked is the subject's own unit
      # test, and no measurement beats that prior, so those go first as a block.
      # Within each block comes the test spending the largest share of its own
      # footprint inside this subject, since a test that exists for this code
      # asserts on it where a feature spec passing through may swallow the
      # difference. Reach breaks the remaining ties, because a test that ran
      # more of the subject's lines is likelier to have run the mutated one.
      def order(covering, subject)
        named, rest = covering.partition { |test, _lines, _footprint| expression_match?(subject, test) }

        (by_focus(named) + by_focus(rest)).map(&:first)
      end

      # The test id breaks a full tie, so the order depends on the recording's
      # content rather than on the order a coverage tool happened to write it.
      def by_focus(covering)
        covering.sort_by { |test, lines, footprint| [-Rational(lines, footprint), -lines, test.id] }
      end

      # The question the expression selector asks of one test, rather than the
      # set it builds by asking it of every test in the suite.
      def expression_match?(subject, test)
        subject.match_expressions.any? do |match_expression|
          test.expressions.any? { |test_expression| match_expression.prefix?(test_expression) }
        end
      end

      # Tests by the location the recording would name them under. A location
      # holds more than one test whenever a framework generates examples from
      # one line, so the value is a list.
      def index
        integration.available_tests.each_with_object({}) do |test, index|
          location = test.location or next

          (index[context_map.normalize(location)] ||= []) << test
        end
      end
      memoize :index
    end # ContextMap
  end # Selector
end # Mutant
