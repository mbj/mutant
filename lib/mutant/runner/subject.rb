module Mutant
  class Runner
    # Subject specific runner
    class Subject < self

      # Return mutation runners
      #
      # @return [Enumerable<Runner::Mutation>]
      #
      # @api private
      #
      attr_reader :mutations

      # Initialize object
      #
      # @param [Configuration] config
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

    private

      # Perform operation
      #
      # @return [undefined]
      #
      # @api private
      #
      def run
        @mutations = @subject.map do |mutation|
          Mutation.new(config, mutation)
        end
      end

    end
  end
end
