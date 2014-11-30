module Mutant
  class Runner
    # Job scheduler
    class Scheduler
      include Concord.new(:env)

      # Initialize object
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(*)
        super
        @index           = 0
        @start           = Time.now
        @active_jobs     = Set.new
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
        Status.new(
          env_result:  env_result,
          done:        done?,
          active_jobs: @active_jobs.dup
        )
      end

      # Return next job
      #
      # @return [Job]
      #   in case there is a next job
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      def next_job
        return unless next_mutation?

        Job.new(
          mutation: mutations.fetch(@index),
          index:    @index
        ).tap do |job|
          @index += 1
          @active_jobs << job
        end
      end

      # Consume job result
      #
      # @param [JobResult] job_result
      #
      # @return [self]
      #
      # @api private
      #
      def job_result(job_result)
        @active_jobs.delete(job_result.job)
        mutation_result(job_result.result)
        self
      end

    private

      # Test if mutation run is done
      #
      # @return [Boolean]
      #
      # @api private
      #
      def done?
        !env_result.continue? || (!next_mutation? && @active_jobs.empty?)
      end

      # Handle mutation finish
      #
      # @param [Result::Mutation] mutation_result
      #
      # @return [self]
      #
      # @api private
      #
      def mutation_result(mutation_result)
        mutation = mutation_result.mutation

        original = @subject_results[mutation.subject]

        @subject_results[mutation.subject] = original.update(
          mutation_results: (original.mutation_results.dup << mutation_result)
        )
      end

      # Test if a next mutation exist
      #
      # @return [Boolean]
      #
      # @api private
      #
      def next_mutation?
        mutations.length > @index
      end

      # Return mutations
      #
      # @return [Array<Mutation>]
      #
      # @api private
      #
      def mutations
        env.mutations
      end

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
