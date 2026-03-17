# frozen_string_literal: true

module Mutant
  class Mutation
    module Runner
      class Sink
        include Parallel::Sink

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
            env:,
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
        # @param [Parallel::Response] response
        #
        # @return [self]
        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        def response(response)
          fail response.error if response.error

          mutation        = env.mutations.fetch(response.result.mutation_index)
          subject         = mutation.subject
          mutation_result = mutation_result(mutation, response.result)

          @subject_results[subject] = Result::Subject.new(
            amount_mutations: subject.mutations.length,
            coverage_results: previous_coverage_results(subject).dup << coverage_result(mutation_result),
            identification:   subject.identification,
            node:             subject.node,
            source:           subject.source,
            source_path:      subject.source_path.to_s,
            tests:            env.selections.fetch(subject)
          )

          self
        end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      private

        def coverage_result(mutation_result)
          Result::Coverage.new(
            mutation_result:,
            criteria_result: mutation_result.criteria_result(env.config.coverage_criteria)
          )
        end

        def mutation_result(mutation, mutation_index_result)
          Result::Mutation.new(
            isolation_result:        mutation_index_result.isolation_result,
            mutation_diff:           mutation.diff.diff,
            mutation_identification: mutation.identification,
            mutation_node:           mutation.node,
            mutation_source:         mutation.source,
            mutation_type:           mutation.class::SYMBOL,
            runtime:                 mutation_index_result.runtime
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
