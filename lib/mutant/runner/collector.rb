module Mutant
  class Runner
    # Parallel process collector
    class Collector
      include Concord::Public.new(:env)

      # Initialize object
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(*)
        super
        @start                = Time.now
        @aggregate            = Hash.new { |hash, key| hash[key] = [] }
        @active               = Set.new
        @last_mutation_result = nil
      end

      # Return last mutation result
      #
      # @return [Result::Mutation]
      #   if there is a last mutation result
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      attr_reader :last_mutation_result

      # Return active subject results
      #
      # @return [Array<Result::Subject>]
      #
      # @api private
      #
      def active_subject_results
        active_subjects.map(&method(:subject_result))
      end

      # Return current result
      #
      # @return [Result::Env]
      #
      # @api private
      #
      def result
        Result::Env.new(
          env:             env,
          runtime:         Time.now - @start,
          subject_results: subject_results
        )
      end

      # Register mutation start
      #
      # @param [Mutation] mutation
      #
      # @return [self]
      #
      # @api private
      #
      def start(mutation)
        @active << mutation
        self
      end

      # Handle mutation finish
      #
      # @param [Result::Mutation] mutation_result
      #
      # @return [self]
      #
      # @api private
      #
      def finish(mutation_result)
        @last_mutation_result = mutation_result

        mutation = mutation_result.mutation
        @active.delete(mutation)

        @aggregate[mutation.subject] << mutation_result

        self
      end

    private

      # Return current subject results
      #
      # @return [Array<Result::Subject>]
      #
      # @api private
      #
      def subject_results
        env.subjects.map(&method(:subject_result))
      end

      # Return active subjects
      #
      # @return [Array<Subject>]
      #
      # @api private
      #
      def active_subjects
        @active.each_with_object(Set.new) do |mutation, subjects|
          subjects << mutation.subject
        end.sort_by(&:identification)
      end

      # Return current subject result
      #
      # @param [Subject] subject
      #
      # @return [Array<Subject::Result>]
      #
      # @api private
      #
      def subject_result(subject)
        mutation_results = @aggregate[subject].sort_by(&:index)

        Result::Subject.new(
          subject:          subject,
          runtime:          mutation_results.map(&:runtime).inject(0.0, :+),
          mutation_results: mutation_results
        )
      end

    end # Collector
  end # Runner
end # Mutant
