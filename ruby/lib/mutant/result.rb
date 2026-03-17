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

    private_constant(:CoverageMetric, :ClassMethods)

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
      def failed_subject_results = subject_results.reject(&:success?)

      sum :amount_mutation_results, :subject_results
      sum :amount_mutations_alive,  :subject_results
      sum :amount_mutations_killed, :subject_results
      sum :amount_timeouts,         :subject_results
      sum :killtime,                :subject_results

      # Amount of mutations
      #
      # @return [Integer]
      def amount_mutations = env.mutations.length

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
      def failed_test_results = test_results.reject(&:success?)
      memoize :failed_test_results

      def stop?
        env.config.fail_fast && !test_results.all?(&:success?)
      end

      def testtime = test_results.map(&:runtime).sum(0.0)

      def amount_tests = env.integration.all_tests.length

      def amount_test_results = test_results.length

      def amount_tests_failed = failed_test_results.length

      def amount_tests_success = test_results.count(&:passed)
    end # TestEnv

    class CoverageCriteria
      include Result, Anima.new(*Config::CoverageCriteria.anima.attribute_names)

      # Test if one coverage criteria indicates success
      #
      # @return [Boolean]
      def success?
        process_abort || test_result || timeout
      end

      JSON = Transform::JSON.for_anima(self)
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
        :mutation_diff,
        :mutation_identification,
        :mutation_node,
        :mutation_source,
        :mutation_type,
        :runtime
      )

      TEST_PASS_SUCCESS = {
        'evil'    => false,
        'neutral' => true,
        'noop'    => true
      }.freeze

      private_constant(:TEST_PASS_SUCCESS)

      # Create mutation criteria results
      #
      # @param [Result::CoverageCriteria]
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
      def killtime = isolation_result.value&.runtime || 0.0

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
        isolation_result.valid_value? && TEST_PASS_SUCCESS.fetch(mutation_type).equal?(isolation_result.value.passed)
      end
      memoize :test_result_success?

      dump = Transform::Success.new(
        block: lambda do |object|
          {
            'isolation_result'        => Isolation::Result::JSON.dump(object.isolation_result).from_right,
            'mutation_diff'           => object.mutation_diff,
            'mutation_identification' => object.mutation_identification,
            'mutation_node'           => object.mutation_source,
            'mutation_source'         => object.mutation_source,
            'mutation_type'           => object.mutation_type,
            'runtime'                 => object.runtime
          }
        end
      )

      parse_node = Transform::Block.capture(:parse_node) do |source|
        Either.wrap_error(::Parser::SyntaxError) { Unparser.parse(source) }
          .lmap(&:message)
      end

      load = Transform::Sequence.new(
        steps: [
          Transform::Hash.new(
            required: [
              Transform::Hash::Key.new(value: 'isolation_result', transform: Isolation::Result::JSON.load_transform),
              Transform::Hash::Key.new(value: 'mutation_diff',    transform: Transform::OPTIONAL_STRING),
              Transform::Hash::Key.new(value: 'mutation_identification', transform: Transform::STRING),
              Transform::Hash::Key.new(value: 'mutation_node',    transform: parse_node),
              Transform::Hash::Key.new(value: 'mutation_source',  transform: Transform::STRING),
              Transform::Hash::Key.new(value: 'mutation_type',    transform: Transform::STRING),
              Transform::Hash::Key.new(value: 'runtime',          transform: Transform::FLOAT)
            ],
            optional: []
          ),
          Transform::Hash::Symbolize.new,
          Transform::Success.new(block: method(:new).to_proc)
        ]
      )

      JSON = Transform::JSON.new(dump_transform: dump, load_transform: load)
    end # Mutation

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

      dump = Transform::Success.new(
        block: lambda do |object|
          {
            'mutation_result' => Mutation::JSON.dump(object.mutation_result).from_right,
            'criteria_result' => CoverageCriteria::JSON.dump(object.criteria_result).from_right
          }
        end
      )

      load = Transform::Sequence.new(
        steps: [
          Transform::Hash.new(
            required: [
              Transform::Hash::Key.new(value: 'mutation_result', transform: Mutation::JSON.load_transform),
              Transform::Hash::Key.new(value: 'criteria_result', transform: CoverageCriteria::JSON.load_transform)
            ],
            optional: []
          ),
          Transform::Hash::Symbolize.new,
          Transform::Success.new(block: method(:new).to_proc)
        ]
      )

      JSON = Transform::JSON.new(dump_transform: dump, load_transform: load)
    end # Coverage

    # Subject result
    class Subject
      include CoverageMetric, Result, Anima.new(
        :amount_mutations,
        :coverage_results,
        :identification,
        :node,
        :source,
        :source_path,
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
      def uncovered_results = coverage_results.reject(&:success?)
      memoize :uncovered_results

      # Amount of mutations
      #
      # @return [Integer]
      def amount_mutation_results = coverage_results.length

      # Amount of mutations
      #
      # @return [Integer]
      def amount_timeouts = coverage_results.count(&:timeout?)

      # Number of killed mutations
      #
      # @return [Integer]
      def amount_mutations_killed = covered_results.length

      # Number of alive mutations
      #
      # @return [Integer]
      def amount_mutations_alive = uncovered_results.length

    private

      def covered_results = coverage_results.select(&:success?)
      memoize :covered_results

      dump = Transform::Success.new(
        block: lambda do |object|
          {
            'amount_mutations' => object.amount_mutations,
            'coverage_results' => object.coverage_results.map { |cr| Coverage::JSON.dump(cr).from_right },
            'identification'   => object.identification,
            'node'             => object.source,
            'source'           => object.source,
            'source_path'      => object.source_path,
            'tests'            => object.tests.map(&:identification)
          }
        end
      )

      parse_node = Transform::Block.capture(:parse_node) do |source|
        Either.wrap_error(::Parser::SyntaxError) { Unparser.parse(source) }
          .lmap(&:message)
      end

      load_test = Transform::Success.new(
        block: ->(id) { Mutant::Test.new(expressions: EMPTY_ARRAY, id:) }
      )

      load = Transform::Sequence.new(
        steps: [
          Transform::Hash.new(
            required: [
              Transform::Hash::Key.new(value: 'amount_mutations', transform: Transform::INTEGER),
              Transform::Hash::Key.new(value: 'coverage_results', transform: Transform::Array.new(transform: Coverage::JSON.load_transform)),
              Transform::Hash::Key.new(value: 'identification',   transform: Transform::STRING),
              Transform::Hash::Key.new(value: 'node',             transform: parse_node),
              Transform::Hash::Key.new(value: 'source',           transform: Transform::STRING),
              Transform::Hash::Key.new(value: 'source_path',      transform: Transform::STRING),
              Transform::Hash::Key.new(value: 'tests',            transform: Transform::Array.new(transform: load_test))
            ],
            optional: []
          ),
          Transform::Hash::Symbolize.new,
          Transform::Success.new(block: method(:new).to_proc)
        ]
      )

      JSON = Transform::JSON.new(dump_transform: dump, load_transform: load)
    end # Subject
  end # Result
end # Mutant
