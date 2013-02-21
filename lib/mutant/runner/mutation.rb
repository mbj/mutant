module Mutant
  class Runner
    # Mutation runner
    class Mutation < self

      # Return killer instance
      #
      # @return [Killer]
      #
      # @api private
      #
      attr_reader :killer

      # Initialize object
      #
      # @param [Configuration] config
      # @param [Mutation] mutation
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(config, mutation)
        @mutation = mutation
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
        @killer = config.strategy(@mutation).kill(@mutation)
      end

    end
  end
end
