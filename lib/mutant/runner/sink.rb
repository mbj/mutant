# frozen_string_literal: true

module Mutant
  module Runner
    class Sink
      include Concord.new(:env)

      # Initialize object
      #
      # @return [undefined]
      def initialize(*)
        super
        @start           = env.world.timer.now
        @subject_results = {}
      end

      # Runner status
      #
      # @return [Result::Env]
      def status
        Result::Env.new(
          env:             env,
          runtime:         env.world.timer.now - @start,
          subject_results: @subject_results.values
        )
      end

      # Test if scheduling stopped
      #
      # @return [Boolean]
      def stop?
        status.stop?
      end

      # Handle mutation finish
      #
      # @param [Result::Mutation] mutation_result
      #
      # @return [self]
      def result(mutation_result)
        subject = mutation_result.mutation.subject

        @subject_results[subject] = Result::Subject.new(
          subject:          subject,
          mutation_results: previous_mutation_results(subject) + [mutation_result],
          tests:            env.selections.fetch(subject)
        )

        self
      end

    private

      def previous_mutation_results(subject)
        subject_result = @subject_results.fetch(subject) { return EMPTY_ARRAY }
        subject_result.mutation_results
      end

    end # Sink
  end # Runner
end # Mutant
