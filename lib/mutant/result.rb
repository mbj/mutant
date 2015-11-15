module Mutant
  # Namespace and mixon module for results
  module Result

    # Coverage mixin
    module Coverage
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
      def sum(name, collection)
        define_method(name) do
          public_send(collection).map(&name).reduce(0, :+)
        end
        memoize(name)
      end
    end # ClassMethods

    private_constant(*constants(false))

    # Mutant overhead running mutatet tests
    #
    # This is NOT the overhead of mutation testing, just an engine specific
    # measurement for the efficiency of the parellelization engine, kill
    # isolation etc.
    #
    # @return [Float]
    def overhead
      runtime - killtime
    end

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
      include Coverage, Result, Anima.new(
        :env,
        :runtime,
        :subject_results
      )

      # Test if run is successful
      #
      # @return [Boolean]
      def success?
        coverage.eql?(env.config.expected_coverage)
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
      sum :killtime,                :subject_results

      # Amount of mutations
      #
      # @return [Fixnum]
      def amount_mutations
        env.mutations.length
      end

      # Amount of subjects
      #
      # @return [Fixnum]
      def amount_subjects
        env.subjects.length
      end

    end # Env

    # Test result
    class Test
      include Result, Anima.new(
        :output,
        :passed,
        :runtime,
        :tests
      )
    end # Test

    # Subject result
    class Subject
      include Coverage, Result, Anima.new(
        :mutation_results,
        :subject,
        :tests
      )

      sum :killtime, :mutation_results
      sum :runtime,  :mutation_results

      # Test if subject was processed successful
      #
      # @return [Boolean]
      def success?
        alive_mutation_results.empty?
      end

      # Test if runner should continue on subject
      #
      # @return [Boolean]
      def continue?
        mutation_results.all?(&:success?)
      end

      # Killed mutations
      #
      # @return [Array<Result::Mutation>]
      def alive_mutation_results
        mutation_results.reject(&:success?)
      end
      memoize :alive_mutation_results

      # Amount of mutations
      #
      # @return [Fixnum]
      def amount_mutation_results
        mutation_results.length
      end

      # Amount of mutations
      #
      # @return [Fixnum]
      def amount_mutations
        subject.mutations.length
      end

      # Number of killed mutations
      #
      # @return [Fixnum]
      def amount_mutations_killed
        killed_mutation_results.length
      end

      # Number of alive mutations
      #
      # @return [Fixnum]
      def amount_mutations_alive
        alive_mutation_results.length
      end

      # Alive mutations
      #
      # @return [Array<Result::Mutation>]
      def killed_mutation_results
        mutation_results.select(&:success?)
      end
      memoize :killed_mutation_results

    end # Subject

    # Mutation result
    class Mutation
      include Result, Anima.new(
        :mutation,
        :test_result
      )

      # The runtime
      #
      # @return [Float]
      def runtime
        test_result.runtime
      end

      alias_method :killtime, :runtime

      # Test if mutation was handled successfully
      #
      # @return [Boolean]
      def success?
        mutation.class.success?(test_result)
      end

    end # Mutation
  end # Result
end # Mutant
