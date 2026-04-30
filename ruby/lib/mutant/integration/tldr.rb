# frozen_string_literal: true

require 'mutant'
require 'tldr'
require 'mutant/tldr/coverage'

class TLDR
  module Run
    # Prevent autorun from running tests when the VM closes.
    #
    # Mutant needs control about the exit status of the VM and the moment of test
    # execution.
    #
    # @api private
    #
    # @return [nil]
    def self.at_exit!(*); end
  end # Run

  # Defang argv parsing — `tldr/autorun` evaluates `ArgvParser.new.parse(ARGV)`
  # eagerly before passing the result to the no-op'd `at_exit!`, which would
  # raise on mutant's own CLI flags.
  class ArgvParser
    def parse(*); end
  end # ArgvParser
end # TLDR

module Mutant
  class Integration
    # tldr integration
    class Tldr < self
      TEST_FILE_PATTERN     = './test/**/{test_*,*_test}.rb'
      IDENTIFICATION_FORMAT = 'tldr:%s#%s'
      CONFIG_OPTIONS        = {
        cli_defaults:  false,
        config_path:   nil,
        emoji:         false,
        fail_fast:     false,
        helper_paths:  [],
        load_paths:    [],
        no_helper:     true,
        no_prepend:    true,
        parallel:      false,
        prepend_paths: [],
        reporter:      'Mutant::Integration::Tldr::Reporter',
        timeout:       -1,
        warnings:      false
      }.freeze

      # Quiet tldr reporter
      class Reporter
        def after_test(*) = nil
      end # Reporter

      # Compose a test class with one of its test methods
      class TestCase
        include Adamantium, Anima.new(:tldr_test)

        # Identification string
        #
        # @return [String]
        def identification = IDENTIFICATION_FORMAT % [klass, test_method]
        memoize :identification

        # Run test case
        #
        # TLDR::Runner terminates via Kernel.exit after every run. Kernel.exit
        # raises SystemExit, so we can safely catch that here and convert the
        # runner status into mutant's boolean result. Timeouts and fail-fast are
        # disabled in the config, avoiding TLDR's hard-exit paths.
        #
        # @param [TLDR::Config] config
        # @param [TLDR::Strategizer::Strategy] strategy
        #
        # @return [Boolean]
        def call(config, strategy)
          runner = ::TLDR::Runner.new
          runner.run(config, ::TLDR::Plan.new([tldr_test], strategy))
        rescue SystemExit => exception
          exception.status.zero?
        rescue StandardError
          false
        end

        # Parse expressions
        #
        # @param [ExpressionParser] parser
        #
        # @return [Array<Expression>]
        def expressions(parser)
          klass.resolve_cover_expressions.to_a.map do |value|
            parser.call(expand_constant(value)).from_right
          end
        end

        def klass = tldr_test.test_class

        def test_method = tldr_test.method_name.to_sym

      private

        def expand_constant(value)
          case value
          when Class, Module
            "#{value.name}*"
          else
            value
          end
        end
      end # TestCase

      private_constant(*constants(false))

      # Setup integration
      #
      # @return [self]
      def setup
        plan

        self
      end

      # Call test integration
      #
      # @param [Array<Test>] tests
      #
      # @return [Result::Test]
      def call(tests)
        test_cases = tests.map(&all_tests_index.public_method(:fetch))
        start      = timer.now

        passed = test_cases.all? { |test_case| test_case.call(config, sequential_strategy) }

        Result::Test.new(
          job_index: nil,
          output:    LogCapture::String.new(content: ''),
          passed:,
          runtime:   timer.now - start
        )
      end

      # All tests exposed by this integration
      #
      # @return [Array<Test>]
      def all_tests = all_tests_index.keys
      memoize :all_tests

      alias_method :available_tests, :all_tests

    private

      def all_tests_index
        all_test_cases.to_h do |test_case|
          [construct_test(test_case), test_case]
        end
      end
      memoize :all_tests_index

      def construct_test(test_case)
        Test.new(
          id:          test_case.identification,
          expressions: test_case.expressions(expression_parser)
        )
      end

      def all_test_cases
        plan.tests.map do |test|
          TestCase.new(tldr_test: test)
        end
      end

      def test_paths
        Pathname.glob(TEST_FILE_PATTERN).map(&:to_s)
      end
      memoize :test_paths

      def config
        ::TLDR::Config.new(
          **CONFIG_OPTIONS,
          paths: test_paths,
          seed:  world.random.srand
        ).freeze
      end
      memoize :config

      def plan
        ::TLDR::Planner.new.plan(config)
      end
      memoize :plan

      def sequential_strategy
        ::TLDR::Strategizer::Strategy.new(parallel?: false)
      end
      memoize :sequential_strategy
    end # Tldr
  end # Integration
end # Mutant
