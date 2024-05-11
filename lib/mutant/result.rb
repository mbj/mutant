# frozen_string_literal: true

module Mutant
  # Namespace and mixin module for results
  module Result

    # CoverageMetric mixin
    module CoverageMetric
      FULL_COVERAGE = Rational(1).freeze
      private_constant(*constants(false))

      # Observed coverage
      #
      # @return [Rational]
      def coverage
        if amount_mutation_results.zero?
          FULL_COVERAGE
        else
          Rational(amount_mutations_killed, amount_mutation_results)
        end
      end
    end # CoverageMetric

    # Class level mixin
    module ClassMethods

      # Generate a sum method from name and collection
      #
      # @param [Symbol] name
      #   the attribute name on collection item and method name to use
      #
      # @param [Symbol] collection
      #   the attribute name used to receive collection
      #
      # @return [undefined]
      def sum(name, collection)
        define_method(name) do
          public_send(collection).map(&name).reduce(0, :+)
        end
        memoize(name)
      end

      # Delegate a method to child
      def delegate(name, target)
        define_method(name) do
          public_send(target).public_send(name)
        end
      end
    end # ClassMethods

    private_constant(*constants(false))

    # Hook called when module gets included
    #
    # @param [Class, Module] host
    #
    # @return [undefined]
    def self.included(host)
      host.class_eval do
        include Adamantium
        extend ClassMethods
      end
    end

    # Env result object
    class Env
      include CoverageMetric, Result, Anima.new(
        :env,
        :runtime,
        :subject_results
      )

      # Test if run is successful
      #
      # @return [Boolean]
      def success?
        coverage.eql?(Rational(1))
      end
      memoize :success?

      # Failed subject results
      #
      # @return [Array<Result::Subject>]
      def failed_subject_results
        subject_results.reject(&:success?)
      end

      sum :amount_mutation_results, :subject_results
      sum :amount_mutations_alive,  :subject_results
      sum :amount_mutations_killed, :subject_results
      sum :amount_timeouts,         :subject_results
      sum :killtime,                :subject_results

      # Amount of mutations
      #
      # @return [Integer]
      def amount_mutations
        env.mutations.length
      end

      # Test if processing needs to stop
      #
      # @return [Boolean]
      #
      def stop?
        env.config.fail_fast && !subject_results.all?(&:success?)
      end
    end # Env

    # TestEnv result object
    class TestEnv
      include Result, Anima.new(
        :env,
        :runtime,
        :test_results
      )

      # Test if run is successful
      #
      # @return [Boolean]
      def success?
        amount_tests_failed.equal?(0)
      end
      memoize :success?

      # Failed subject results
      #
      # @return [Array<Result::Test>]
      def failed_test_results
        test_results.reject(&:success?)
      end
      memoize :failed_test_results

      def stop?
        env.config.fail_fast && !test_results.all?(&:success?)
      end

      def testtime
        test_results.map(&:runtime).sum(0.0)
      end

      def amount_tests
        env.integration.all_tests.length
      end

      def amount_test_results
        test_results.length
      end

      def amount_tests_failed
        failed_test_results.length
      end

      def amount_tests_success
        test_results.count(&:passed)
      end
    end # TestEnv

    # Test result
    class Test
      include Anima.new(:job_index, :passed, :runtime, :output)

      alias_method :success?, :passed

      class VoidValue < self
        include Singleton

        # Initialize object
        #
        # @return [undefined]
        def initialize
          super(
            job_index: nil,
            output:    '',
            passed:    false,
            runtime:   0.0
          )
        end
      end # VoidValue
    end # Test

    # Subject result
    class Subject
      include CoverageMetric, Result, Anima.new(
        :coverage_results,
        :subject,
        :tests
      )

      sum :killtime, :coverage_results
      sum :runtime,  :coverage_results

      # Test if subject was processed successful
      #
      # @return [Boolean]
      def success?
        uncovered_results.empty?
      end

      # Alive mutations
      #
      # @return [Array<Result::Coverage>]
      def uncovered_results
        coverage_results.reject(&:success?)
      end
      memoize :uncovered_results

      # Amount of mutations
      #
      # @return [Integer]
      def amount_mutation_results
        coverage_results.length
      end

      # Amount of mutations
      #
      # @return [Integer]
      def amount_timeouts
        coverage_results.count(&:timeout?)
      end

      # Amount of mutations
      #
      # @return [Integer]
      def amount_mutations
        subject.mutations.length
      end

      # Number of killed mutations
      #
      # @return [Integer]
      def amount_mutations_killed
        covered_results.length
      end

      # Number of alive mutations
      #
      # @return [Integer]
      def amount_mutations_alive
        uncovered_results.length
      end

    private

      def covered_results
        coverage_results.select(&:success?)
      end
      memoize :covered_results

    end # Subject

    # Coverage of a mutation against criteria
    class Coverage
      include Result, Anima.new(
        :mutation_result,
        :criteria_result
      )

      delegate :killtime, :mutation_result
      delegate :runtime,  :mutation_result
      delegate :success?, :criteria_result
      delegate :timeout?, :mutation_result
    end # Coverage

    class CoverageCriteria
      include Result, Anima.new(*Config::CoverageCriteria.anima.attribute_names)

      # Test if one coverage criteria indicates success
      #
      # @return [Boolean]
      def success?
        process_abort || test_result || timeout
      end
    end

    class MutationIndex
      include Anima.new(
        :isolation_result,
        :mutation_index,
        :runtime
      )
    end # MutationIndex

    # Mutation result
    class Mutation
      include Result, Anima.new(
        :isolation_result,
        :mutation,
        :runtime
      )

      # Create mutation criteria results
      #
      # @praam [Result::CoverageCriteria]
      def criteria_result(coverage_criteria)
        CoverageCriteria.new(
          process_abort: coverage_criteria.process_abort && process_abort?,
          test_result:   coverage_criteria.test_result   && test_result_success?,
          timeout:       coverage_criteria.timeout       && timeout?
        )
      end

      # Time the tests had been running
      #
      # @return [Float]
      def killtime
        isolation_result.value&.runtime || 0.0
      end

      # Test for timeout
      #
      # @return [Boolean]
      def timeout?
        !isolation_result.timeout.nil?
      end

      # Test for unexpected process abort
      #
      # @return [Boolean]
      def process_abort?
        process_status = isolation_result.process_status or return false

        !timeout? && !process_status.success?
      end

    private

      # Test if mutation was handled successfully
      #
      # @return [Boolean]
      def test_result_success?
        isolation_result.valid_value? && mutation.class.success?(isolation_result.value)
      end
      memoize :test_result_success?

    end # Mutation
  end # Result
end # Mutant
