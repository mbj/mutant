# frozen_string_literal: true

module Mutant
  class Mutation
    module Runner
      class Sink
        include Anima.new(:env)

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
        # @param [Result::MutationIndex] mutation_index_result
        #
        # @return [self]
        def result(mutation_index_result)
          mutation_result = mutation_result(mutation_index_result)

          subject = mutation_result.mutation.subject

          @subject_results[subject] = Result::Subject.new(
            subject:          subject,
            coverage_results: previous_coverage_results(subject).dup << coverage_result(mutation_result),
            tests:            env.selections.fetch(subject)
          )

          self
        end

      private

        def coverage_result(mutation_result)
          Result::Coverage.new(
            mutation_result: mutation_result,
            criteria_result: mutation_result.criteria_result(env.config.coverage_criteria)
          )
        end

        def mutation_result(mutation_index_result)
          Result::Mutation.new(
            isolation_result: mutation_index_result.isolation_result,
            mutation:         env.mutations.fetch(mutation_index_result.mutation_index),
            runtime:          mutation_index_result.runtime
          )
        end

        def previous_coverage_results(subject)
          subject_result = @subject_results.fetch(subject) { return EMPTY_ARRAY }
          subject_result.coverage_results
        end

      end # Sink
    end # Runner
  end # Mutation
end # Mutant
