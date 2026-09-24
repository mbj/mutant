# frozen_string_literal: true

module Mutant
  class Mutation
    module Runner
      class Sink
        include Parallel::Sink

        include Anima.new(:env)

        # Minimum seconds between two session flushes
        FLUSH_INTERVAL = 1.0

        # Initialize object
        #
        # @return [undefined]
        def initialize(*)
          super
          @start           = env.world.timer.now
          @last_flush_at   = @start - FLUSH_INTERVAL
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
          coverage        = coverage_result(mutation_result)

          @subject_results[subject] = Result::Subject.new(
            amount_mutations:  subject.mutations.length,
            coverage_results:  previous_coverage_results(subject).dup << coverage,
            expression_syntax: subject.expression.syntax,
            identification:    subject.identification,
            node:              subject.node,
            source:            subject.source,
            source_path:       subject.source_path.to_s,
            tests:             env.selections.fetch(subject)
          )

          flush_session unless coverage.success?

          self
        end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      private

        # Persist the session on alive mutations, so survivors are
        # inspectable while a long run is still going, rather than only
        # after its final write.
        #
        # Alive mutations can arrive far faster than once per second, and
        # each flush serializes the whole result tree on the main process,
        # so flushes are rate limited against the monotonic timer. A
        # survivor that lands inside the suppressed window is picked up by
        # the next flush, or by the final write in the runner.
        def flush_session
          now = env.world.timer.now

          return if (now - @last_flush_at) < FLUSH_INTERVAL

          @last_flush_at = now

          Result::JSONWriter.new(env:, result: status).call
        end

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
