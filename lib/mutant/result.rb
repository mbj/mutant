module Mutant
  # Namespace and mixon module for results
  module Result

    # Hook called when module gets included
    #
    # @param [Class, Module] host
    #
    # @return [undefined]
    #
    # @api private
    #
    def self.included(host)
      host.class_eval do
        include Adamantium::Flat, Anima::Update
        extend ClassMethods
      end
    end

    # Mixin generator for relative measurments in result
    class Relative < Module
      include Concord.new(:method_name, :left, :right)

    private

      def included(host)
        define_relative_method(host)
        define_relative_percent_method(host)
      end

      def define_relative_method(host)
        left, right = left(), right()

        host.__send__(:define_method, method_name) do
          left_value = public_send(left)
          right_value = public_send(right)

          return Rational(0) if left_value.zero?

          Rational(left_value, right_value)
        end
      end

      def define_relative_percent_method(host)
        method_name = method_name()

        host.__send__(:define_method, "#{method_name}_percent") do
          public_send(method_name) * 100
        end
      end
    end

    Coverage = Relative.new(:coverage, :amount_mutations_killed, :amount_mutation_results)

    # Overhead module
    module Overhead

      # Return overhead
      #
      # @return [Float]
      #
      # @api private
      #
      def overhead
        return 0.0 if worktime.zero?
        overhead_time / worktime
      end

      # Return time spend in addition to runtime
      #
      # @return [Float]
      #
      # @api private
      #
      def overhead_time
        runtime - worktime
      end

      # Return overhead percent
      #
      # @return [Float]
      #
      # @api private
      #
      def overhead_percent
        overhead * 100
      end

    end # Overhead

    # Class level mixin
    module ClassMethods

    private

      # Generate a sum method from name and collection
      #
      # @param [Symbol] name
      #   the attribute name on collection item and method name to use
      #
      # @param [Symbol] collection
      #   the attribute name used to receive collection
      #
      # @return [undefined]
      #
      # @api private
      #
      def sum(name, collection)
        define_method(name) do
          public_send(collection).map(&name).reduce(0, :+)
        end
        memoize(name)
      end
    end # ClassMethods

    # Env result object
    class Env
      include(
        Result,
        Coverage,
        Overhead,
        Relative.new(:progress, :amount_mutation_results, :amount_mutations),
        Anima.new(:runtime, :env, :subject_results)
      )

      COVERAGE_PRECISION = 1

      # Test if run is successful
      #
      # @return [Boolean]
      #
      # @api private
      #
      def success?
        (coverage * 100).to_f.round(COVERAGE_PRECISION).eql?(env.config.expected_coverage.round(COVERAGE_PRECISION))
      end
      memoize :success?

      # Return failed subject results
      #
      # @return [Array<Result::Subject>]
      #
      # @api private
      #
      def failed_subject_results
        subject_results.reject(&:success?)
      end

      sum :amount_tests_tried,        :subject_results
      sum :amount_mutation_results, :subject_results
      sum :amount_mutations_alive,  :subject_results
      sum :amount_mutations_killed, :subject_results
      sum :worktime,                :subject_results

      # Return amount of mutations
      #
      # @return [Fixnum]
      #
      # @api private
      #
      def amount_mutations
        env.mutations.length
      end

      # Return amount of subjects
      #
      # @return [Fixnum]
      #
      # @api private
      #
      def amount_subjects
        env.subjects.length
      end

    end # Env

    # Test result
    class Test
      include Result, Anima.new(
        :tests,
        :output,
        :passed,
        :runtime
      )

      EMPTY = new(
        tests:   EMPTY_ARRAY,
        output:  'No tests executed',
        passed:  true,
        runtime: 0.0
      )

    end # Test

    # Subject result
    class Subject
      include Result, Coverage, Overhead, Anima.new(:subject, :tests, :mutation_results)

      sum :amount_tests_tried, :mutation_results
      sum :worktime,         :mutation_results
      sum :runtime,          :mutation_results

      # Test if subject was processed successful
      #
      # @return [Boolean]
      #
      # @api private
      #
      def success?
        alive_mutation_results.empty?
      end

      # Test if runner should continue on subject
      #
      # @return [Boolean]
      #
      # @api private
      #
      def continue?
        mutation_results.all?(&:success?)
      end

      # Return killed mutations
      #
      # @return [Array<Result::Mutation>]
      #
      # @api private
      #
      def alive_mutation_results
        mutation_results.reject(&:success?)
      end
      memoize :alive_mutation_results

      # Return amount of mutations
      #
      # @return [Fixnum]
      #
      # @api private
      #
      def amount_mutation_results
        mutation_results.length
      end

      # Return amount of mutations
      #
      # @return [Fixnum]
      #
      # @api private
      #
      def amount_mutations
        subject.mutations.length
      end

      # Return number of killed mutations
      #
      # @return [Fixnum]
      #
      # @api private
      #
      def amount_mutations_killed
        killed_mutation_results.length
      end

      # Return number of alive mutations
      #
      # @return [Fixnum]
      #
      # @api private
      #
      def amount_mutations_alive
        alive_mutation_results.length
      end

      # Return alive mutations
      #
      # @return [Array<Result::Mutation>]
      #
      # @api private
      #
      def killed_mutation_results
        mutation_results.select(&:success?)
      end
      memoize :killed_mutation_results

    end # Subject

    # Mutation result
    class Mutation
      include Result, Overhead, Anima.new(:mutation, :test_result)

      # Return runtime
      #
      # @return [Float]
      #
      # @api private
      #
      def runtime
        test_result.runtime
      end

      alias_method :worktime, :runtime

      # Return tests
      #
      # @return [Enumerable<Test>]
      #
      # @api private
      #
      def tests
        test_result.tests
      end

      # Test if mutation was handled successfully
      #
      # @return [Boolean]
      #
      # @api private
      #
      def success?
        mutation.class.success?(test_result)
      end

      # Return amount tests run
      #
      # @return [Fixnum]
      #
      # @api private
      #
      def amount_tests_tried
        test_result.tests.length
      end

    end # Mutation

    # Test trace result
    class TestTrace
      include Result, Overhead, Anima.new(:test, :test_result, :trace)

      # Return time to produce the test trace
      #
      # @return [Float]
      #
      # @api private
      #
      def worktime
        test_result.runtime
      end

      # Test if trace is sucessful
      #
      # @return [Boolean]
      #
      # @api private
      #
      def success?
        test_result.passed
      end

    end # LineTrace

    # Env trace result
    class EnvTrace
      include(
        SimpleInspect,
        Result,
        Overhead,
        Relative.new(:progress, :amount_test_traces, :amount_tests),
        Anima.new(:env, :runtime, :test_traces)
      )

      sum :worktime, :test_traces

      # Return amount of test results
      #
      # @return [Fixnum]
      #
      # @api private
      #
      def amount_test_traces
        test_traces.length
      end

      # Return failed test traces
      #
      # @return [Array<Result::Subject>]
      #
      # @api private
      #
      def failed_test_traces
        test_traces.reject(&:success?)
      end
      memoize :failed_test_traces

      # Return amount of tests
      #
      # @return [Fixnum]
      #
      # @api private
      #
      def amount_tests
        env.config.integration.all_tests.length
      end

      # Test if tracing is successful
      #
      # @return [Boolean]
      #
      # @api private
      #
      def success?
        test_traces.all?(&:success?)
      end

    end # Trace
  end # Result
end # Mutant
