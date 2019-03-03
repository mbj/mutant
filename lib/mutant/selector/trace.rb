# frozen_string_literal: true

module Mutant
  class Selector
    class Trace < self
      include Concord.new(:tests, :test_traces)

      # Tests for subject
      #
      # @param [Subject] subject
      #
      # @return [Maybe<Enumerable<Test>>]
      def call(subject)
        Maybe::Just.new(
          tests.select do |test|
            test_traces.fetch(test.id).include?(subject.trace_location)
          end
        )
      end
    end # Trace
  end # Selector
end # Mutant
