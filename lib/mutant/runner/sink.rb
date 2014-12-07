module Mutant
  class Runner
    # Abstract base class for computation sinks
    class Sink
      include AbstractType

      # Return sink status
      #
      # @return [Object]
      #
      # @api private
      #
      abstract_method :status

      # Test if computation should be stopped
      #
      # @return [Boolean]
      #
      # @api private
      #
      abstract_method :stop?

      # Consume result
      #
      # @param [Object] result
      #
      # @return [self]
      #
      # @api private
      #
      abstract_method :result

      # Mutation result sink
      class Mutation < self
        include Concord.new(:env)

        # Initialize object
        #
        # @return [undefined]
        #
        # @api private
        #
        def initialize(*)
          super
          @start           = Time.now
          @subject_results = Hash.new do |_hash, subject|
            Result::Subject.new(
              subject:          subject,
              tests:            [],
              mutation_results: []
            )
          end
        end

        # Return runner status
        #
        # @return [Status]
        #
        # @api private
        #
        def status
          env_result
        end

        # Test if scheduling stopped
        #
        # @return [Boolean]
        #
        # @api private
        #
        def stop?
          env.config.fail_fast && !env_result.subject_results.all?(&:success?)
        end

        # Handle mutation finish
        #
        # @param [Result::Mutation] mutation_result
        #
        # @return [self]
        #
        # @api private
        #
        def result(mutation_result)
          mutation = mutation_result.mutation

          original = @subject_results[mutation.subject]

          @subject_results[mutation.subject] = original.update(
            mutation_results: (original.mutation_results.dup << mutation_result),
            tests:            mutation_result.test_result.tests
          )

          self
        end

      private

        # Return current result
        #
        # @return [Result::Env]
        #
        # @api private
        #
        def env_result
          Result::Env.new(
            env:             env,
            runtime:         Time.now - @start,
            subject_results: @subject_results.values
          )
        end
      end # Mutation

      # Trace computation sink
      class Trace < self
        include Concord.new(:env)

        # Initialize
        #
        # @return [undefined]
        #
        # @api private
        #
        def initialize(*)
          super

          @start       = Time.now
          @test_traces = []
          @stop        = false
        end

        # Handle line trace result
        #
        # @param [Result::LineTrace] result
        #
        # @api private
        #
        def result(result)
          @test_traces << result
          @stop = !result.test_result.passed

          self
        end

        # Return status
        #
        # @return [EnvTrace]
        #
        # @api private
        #
        def status
          Result::EnvTrace.new(
            env:         env,
            runtime:     Time.now - @start,
            test_traces: @test_traces.dup,
          )
        end

        # Test if processing should stop
        #
        # @return [Boolean]
        #
        # @api private
        #
        def stop?
          @stop
        end

      end # Trace
    end # Sink
  end # Runner
end # Mutant
