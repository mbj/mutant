module Mutant
  # Namespace and mixon module for results
  module Result

    # Coverage mixin
    module Coverage

      # Return coverage
      #
      # @return [Rational]
      #
      # @api private
      #
      def coverage
        return Rational(0) if amount_mutation_results.zero?

        Rational(amount_mutations_killed, amount_mutation_results)
      end

      # Hook called when module gets included
      #
      # @param [Class, Module] host
      #
      # @return [undefined]
      #
      # @api private
      #
      def self.included(host)
        super

        host.memoize(:coverage)
      end

    end # Coverage

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

    # Return overhead
    #
    # @return [Float]
    #
    # @api private
    #
    def overhead
      runtime - killtime
    end

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
        include Adamantium, Anima::Update
        extend ClassMethods
      end
    end

    # Env result object
    class Env
      include Coverage, Result, Anima.new(:runtime, :env, :subject_results)

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

      # Test if runner should continue on env
      #
      # @return [Boolean]
      #
      # @api private
      #
      def continue?
        !env.config.fail_fast || subject_results.all?(&:success?)
      end

      # Return failed subject results
      #
      # @return [Array<Result::Subject>]
      #
      # @api private
      #
      def failed_subject_results
        subject_results.reject(&:success?)
      end

      sum :amount_mutation_results, :subject_results
      sum :amount_mutations_alive,  :subject_results
      sum :amount_mutations_killed, :subject_results
      sum :killtime,                :subject_results

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
    end # Test

    # Subject result
    class Subject
      include Coverage, Result, Anima.new(:subject, :mutation_results)

      sum :killtime, :mutation_results
      sum :runtime,  :mutation_results

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
      include Result, Anima.new(:mutation, :test_result)

      # Return runtime
      #
      # @return [Float]
      #
      # @api private
      #
      def runtime
        test_result.runtime
      end

      alias_method :killtime, :runtime

      # Test if mutation was handled successfully
      #
      # @return [Boolean]
      #
      # @api private
      #
      def success?
        mutation.class.success?(test_result)
      end

    end # Mutation
  end # Result
end # Mutant
