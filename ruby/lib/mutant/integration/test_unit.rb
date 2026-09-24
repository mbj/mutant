# frozen_string_literal: true

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'mutant/test_unit/coverage'

Test::Unit::AutoRunner.need_auto_run = false if defined?(Test::Unit::AutoRunner)

module Mutant
  class Integration
    # Test::Unit integration
    class TestUnit < self
      TEST_FILE_PATTERN     = './{test,test_unit}/**/{test_*,*_test}.rb'
      IDENTIFICATION_FORMAT = 'test-unit:%s#%s'

      # Compose a runnable with test method
      class TestCase
        include Adamantium, Anima.new(:klass, :test_method)

        # Identification string
        #
        # @return [String]
        def identification = IDENTIFICATION_FORMAT % [klass, test_method]
        memoize :identification

        # Run test case
        #
        # @return [Boolean]
        def call
          suite = ::Test::Unit::TestSuite.new
          suite << klass.new(test_method)
          runner = ::Test::Unit::UI::Console::TestRunner.new(
            suite,
            output_level: ::Test::Unit::UI::Console::OutputLevel::SILENT
          )
          runner.start.passed?
        end

        # Where the test method is defined
        #
        # @return [String, nil]
        def location
          path, line = klass.instance_method(test_method).source_location

          "#{path}:#{line}" if path
        end
        memoize :location

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
        Pathname.glob(TEST_FILE_PATTERN)
          .map(&:to_s)
          .reject { |path| path.include?('/vendor/') }
          .each(&world.kernel.public_method(:require))

        self
      end

      # Call test integration
      #
      # @param [Array<Test>] tests
      #
      # @return [Result::Test]
      #
      # rubocop:disable Metrics/MethodLength
      def call(tests)
        test_cases = tests.map(&all_tests_index.public_method(:fetch))
        start      = timer.now

        passed = true
        test_cases.each do |test_case|
          unless test_case.call
            passed = false
            break
          end
        end

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
          expressions: test_case.expressions(expression_parser),
          id:          test_case.identification,
          location:    test_case.location
        )
      end

      def all_test_cases
        ::Test::Unit::TestCase::DESCENDANTS
          .select(&method(:allow_runnable?))
          .flat_map(&method(:test_case))
      end

      def allow_runnable?(klass)
        !klass.equal?(::Test::Unit::TestCase)
      end

      def test_case(runnable)
        runnable.suite.tests.map do |test|
          TestCase.new(klass: runnable, test_method: test.method_name)
        end
      end
    end # TestUnit
  end # Integration
end # Mutant
