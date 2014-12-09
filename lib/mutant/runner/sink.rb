module Mutant
  class Runner
    # Mutation result sink
    class Sink
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
          mutation_results: (original.mutation_results.dup << mutation_result)
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

    end # Scheduler
  end # Runner
end # Mutant
