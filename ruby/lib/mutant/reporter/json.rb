# frozen_string_literal: true

module Mutant
  class Reporter
    # Reporter that emits a single JSON document at the end of analysis
    class JSON < self
      include Anima.new(:output)

      DELAY = Float::INFINITY

      # Build reporter
      #
      # @param [IO] output
      #
      # @return [Reporter::JSON]
      def self.build(output)
        new(output:)
      end

      # Report warning (no-op for JSON)
      #
      # @param [String] _message
      #
      # @return [self]
      def warn(_message) = self

      # Report start (no-op for JSON)
      #
      # @param [Env] _env
      #
      # @return [self]
      def start(_env) = self

      # Report test start (no-op for JSON)
      #
      # @param [Env] _env
      #
      # @return [self]
      def test_start(_env) = self

      # Report progress (no-op for JSON)
      #
      # @param [Parallel::Status] _status
      #
      # @return [self]
      def progress(_status) = self

      # Report test progress (no-op for JSON)
      #
      # @param [Parallel::Status] _status
      #
      # @return [self]
      def test_progress(_status) = self

      # Report delay
      #
      # @return [Float]
      def delay = DELAY

      # Report final mutation analysis results
      #
      # @param [Result::Env] result
      #
      # @return [self]
      def report(result)
        output.puts(::JSON.generate(serialize_env_result(result)))
        self
      end

      # Report final test results
      #
      # @param [Result::TestEnv] result
      #
      # @return [self]
      def test_report(result)
        output.puts(::JSON.generate(serialize_test_env_result(result)))
        self
      end

    private

      def serialize_env_result(result)
        {
          schema_version:  '1.0.0',
          mutant_version:  VERSION,
          report_type:     'mutation_analysis',
          summary:         {
            runtime:  result.runtime,
            killtime: result.killtime,
            coverage: result.coverage,
            mutations: result.amount_mutations,
            results:   result.amount_mutation_results,
            kills:     result.amount_mutations_killed,
            alive:     result.amount_mutations_alive,
            timeouts:  result.amount_timeouts,
            success:   result.success?
          },
          environment:     serialize_environment(result.env),
          subject_results: result.subject_results.map { |sr| serialize_subject_result(sr) }
        }
      end

      def serialize_environment(env)
        {
          subjects:           env.amount_subjects,
          all_tests:          env.amount_all_tests,
          available_tests:    env.amount_available_tests,
          selected_tests:     env.amount_selected_tests,
          test_subject_ratio: env.test_subject_ratio
        }
      end

      def serialize_subject_result(subject_result)
        subject = subject_result.subject

        {
          subject:          subject.identification,
          source_path:      subject.source_path,
          source_line:      subject.source_line,
          source_lines:     { begin: subject.source_lines.begin, end: subject.source_lines.end },
          tests:            subject_result.tests.map(&:identification),
          coverage:         subject_result.coverage,
          mutations_killed: subject_result.amount_mutations_killed,
          mutations_alive:  subject_result.amount_mutations_alive,
          timeouts:         subject_result.amount_timeouts,
          killtime:         subject_result.killtime,
          runtime:          subject_result.runtime,
          alive_mutations:  subject_result.uncovered_results.map { |cr| serialize_alive_mutation(cr) }
        }
      end

      def serialize_alive_mutation(coverage_result)
        mutation_result = coverage_result.mutation_result
        mutation        = mutation_result.mutation

        {
          identification: mutation.identification,
          mutation_type:  mutation.class::SYMBOL,
          code:           mutation.code,
          diff:           mutation.diff.diff,
          criteria:       serialize_criteria_result(coverage_result.criteria_result),
          runtime:        mutation_result.runtime,
          killtime:       mutation_result.killtime
        }
      end

      def serialize_criteria_result(criteria_result)
        {
          test_result:   criteria_result.test_result,
          timeout:       criteria_result.timeout,
          process_abort: criteria_result.process_abort
        }
      end

      def serialize_test_env_result(result)
        {
          schema_version:     '1.0.0',
          mutant_version:     VERSION,
          report_type:        'test_verification',
          summary:            {
            runtime:       result.runtime,
            testtime:      result.testtime,
            tests:         result.amount_tests,
            test_results:  result.amount_test_results,
            tests_failed:  result.amount_tests_failed,
            tests_success: result.amount_tests_success,
            success:       result.success?
          },
          failed_test_results: result.failed_test_results.map { |tr| serialize_test_result(tr) }
        }
      end

      def serialize_test_result(test_result)
        {
          passed:  test_result.passed,
          runtime: test_result.runtime,
          output:  test_result.output
        }
      end

    end # JSON
  end # Reporter
end # Mutant
