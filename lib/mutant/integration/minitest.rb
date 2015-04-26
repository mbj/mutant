require 'minitest'

# monkey patch for minitest
module Minitest
  # Prevent autorun from running tests when the VM closes
  #
  # Mutant needs control about the exit status of the VM and
  # the moment of test execution
  #
  # @api private
  #
  # @return [nil]
  def self.autorun
  end

end # Minitest

module Mutant
  class Integration
    # Minitest integration
    class Minitest < self
      TEST_METHOD_PREFIX = 'test_'.freeze

      register 'minitest'

      # Compose a runnable with test method
      #
      # This looks actually like a missing object on minitest implementation.
      class TestCase
        include Adamantium, Concord.new(:klass, :test_method)

        # Identification string
        #
        # @return [String]
        #
        # @api private
        def identification
          "minitest:#{klass}##{test_method}"
        end
        memoize :identification

        # Run test case
        #
        # @param [Object] reporter
        #
        # @return [Boolean]
        #
        # @api private
        def call(reporter)
          ::Minitest::Runnable.run_one_method(klass, test_method, reporter)
          reporter.passed?
        end

        # Cover expression syntaxes
        #
        # @return [Array<String>]
        #
        # @api private
        def expression_syntax
          klass.cover_expression
        end

      end # TestCase

      private_constant(*constants(false))

      # Setup integration
      #
      # @return [self]
      #
      # @api private
      def setup
        Dir.glob('./test/**/{test_*,*_test}.rb').each(&method(:require))
        self
      end

      # Call test integration
      #
      # @param [Array<Tests>] tests
      #
      # @return [Result::Test]
      #
      # rubocop:disable MethodLength
      #
      # @api private
      def call(tests)
        test_cases = tests.map(&all_tests_index.method(:fetch)).to_set

        output   = StringIO.new
        reporter = self.class.make_reporter(output)

        start = Time.now
        passed = test_cases.all? { |test| test.call(reporter) }
        output.rewind

        Result::Test.new(
          passed:  passed,
          tests:   tests,
          output:  output.read,
          runtime: Time.now - start
        )
      end

      # All tests exposed by this integration
      #
      # @return [Array<Test>]
      #
      # @api private
      def all_tests
        all_tests_index.keys
      end
      memoize :all_tests

    private

      # The index of all tests to runnable test cases
      #
      # @return [Hash<Test,TestCase>]
      #
      # @api private
      def all_tests_index
        self.class.all_test_cases.each_with_object({}) do |test_case, index|
          index[construct_test(test_case)] = test_case
        end
      end
      memoize :all_tests_index

      # Construct test from test case
      #
      # @param [TestCase]
      #
      # @return [Test]
      #
      # @api private
      def construct_test(test_case)
        Test.new(
          id:         test_case.identification,
          expression: config.expression_parser.(test_case.expression_syntax)
        )
      end

      # All minitest test cases
      #
      # @return [Array<TestCase>]
      #
      # @api private
      def self.all_test_cases
        ::Minitest::Runnable.runnables.flat_map(&method(:test_case))
      end

      # Turn a minitest runnable into its test cases
      #
      # @param [Object] runnable
      #
      # @return [Array<TestCase>]
      #
      # @api private
      def self.test_case(runnable)
        runnable.runnable_methods.each_with_object([]) do |method_name, test_cases|
          next unless method_name.start_with?(TEST_METHOD_PREFIX)
          test_cases << TestCase.new(runnable, method_name)
        end
      end
      private_class_method :test_case

      # Reporter used for a specific mutation kjill
      #
      # @param [StringIO] output
      #
      # @api private
      def self.make_reporter(output)
        reporter = ::Minitest::CompositeReporter.new
        reporter << ::Minitest::SummaryReporter.new(output)
        reporter << ::Minitest::ProgressReporter.new(output)
        reporter
      end

    end # Minitest
  end # Integration
end # Mutant
