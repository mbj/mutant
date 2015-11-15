module Mutant
  class Runner
    class Sink
      include Concord.new(:env)

      # Initialize object
      #
      # @return [undefined]
      def initialize(*)
        super
        @start           = Time.now
        @subject_results = {}
      end

      # Runner status
      #
      # @return [Result::Env]
      def status
        Result::Env.new(
          env:             env,
          runtime:         Time.now - @start,
          subject_results: @subject_results.values
        )
      end

      # Test if scheduling stopped
      #
      # @return [Boolean]
      def stop?
        env.config.fail_fast && !status.subject_results.all?(&:success?)
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
          tests:            mutation_result.test_result.tests
        )

        self
      end

    private

      # Return previous results
      #
      # @param [Subject]
      #
      # @return [Array<Result::Mutation>]
      def previous_mutation_results(subject)
        subject_result = @subject_results.fetch(subject) { return EMPTY_ARRAY }
        subject_result.mutation_results
      end

    end # Sink
  end # Runner
end # Mutant
