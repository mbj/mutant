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
        return Rational(0) if amount_mutations.zero?

        Rational(amount_mutations_killed, amount_mutations)
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

        host.memoize :coverage
      end

    end

    # Test if operation is failing
    #
    # @return [Boolean]
    #
    # @api private
    #
    def fail?
      !success?
    end

    # Class level mixin
    module ClassMethods

      # Generate a sum messot from name and collection
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
        memoize name
      end
    end

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
    # @param [Class, Module] hosto
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

    # Env result object
    class Env
      include Coverage, Result, Anima.new(:runtime, :env, :subject_results)

      COVERAGE_PRECISION = 1

      # Test if run was successful
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

      sum :amount_mutations,        :subject_results
      sum :amount_mutations_alive,  :subject_results
      sum :amount_mutations_killed, :subject_results
      sum :killtime,                :subject_results

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
      include Result, Adamantium::Flat, Anima::Update, Anima.new(
        :test,
        :output,
        :mutation,
        :passed,
        :runtime
      )

      # NOTE:
      #
      #  The test is intentionally NOT part of the mashalled data.
      #  In rspec the example group cannot deterministically being marshalled, because
      #  they reference a crazy mix of IO objects, global objects etc.
      #
      MARSHALLED_IVARS = (anima.attribute_names - [:test]).map do |name|
        :"@#{name}"
      end

      # Return killtime
      #
      # @return [Float]
      #
      # @api private
      #
      alias_method :killtime, :runtime

      # Test if mutation test result is successful
      #
      # @return [Boolean]
      #
      # @api private
      #
      def success?
        mutation.killed_by?(self)
      end

      # Return marshallable data
      #
      #
      # @return [Array]
      #
      # @api private
      #
      def marshal_dump
        MARSHALLED_IVARS.map(&method(:instance_variable_get))
      end

      # Load marshalled data
      #
      # @param [Array] array
      #
      # @return [undefined]
      #
      # @api private
      #
      def marshal_load(array)
        MARSHALLED_IVARS.zip(array) do |instance_variable_name, value|
          instance_variable_set(instance_variable_name, value)
        end
      end

    end # Test

    # Subject result
    class Subject
      include Coverage, Result, Anima.new(:subject, :mutation_results, :runtime)

      sum :killtime, :mutation_results

      # Test if subject was processed successful
      #
      # @return [Boolean]
      #
      # @api private
      #
      def success?
        alive_mutation_results.empty?
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
        amount_mutations - amount_mutations_killed
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
      include Result, Anima.new(:runtime, :mutation, :test_results)

      # Test if mutation was handeled successfully
      #
      # @return [Boolean]
      #
      # @api private
      #
      def success?
        test_results.any?(&:success?)
      end

      sum :killtime, :test_results

    end # Mutation

  end # Result
end # Mutant
