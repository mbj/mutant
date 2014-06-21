module Mutant
  class Runner
    # Subject specific runner
    class Subject < self
      include Equalizer.new(:config, :subject)

      # Return subject
      #
      # @return [Subject]
      #
      # @api private
      #
      attr_reader :subject

      register Mutant::Subject

      # Initialize object
      #
      # @param [Config] config
      # @param [Subject] subject
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(config, subject)
        @subject = subject
        super(config)
      end

      # Return mutation runners
      #
      # @return [Enumerable<Runner::Mutation>]
      #
      # @api private
      #
      attr_reader :mutations

      # Return failed mutations
      #
      # @return [Enumerable<Mutation>]
      #
      # @api private
      #
      def failed_mutations
        mutations.reject(&:success?)
      end
      memoize :failed_mutations

      # Test if subject was processed successful
      #
      # @return [Boolean]
      #
      # @api private
      #
      def success?
        failed_mutations.empty?
      end

      # Return tests used to kill mutations on this subject
      #
      # @return [Enumerable<Test>]
      #
      # @api private
      #
      def tests
        config.strategy.tests(subject)
      end
      memoize :tests

    private

      # Perform operation
      #
      # @return [undefined]
      #
      # @api private
      #
      def run
        @mutations = visit_collection(subject.mutations, tests)
      end

    end # Subject
  end # Runner
end # Mutant
