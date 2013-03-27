module Mutant
  class Runner
    # Mutation runner
    class Mutation < self
      include Concord.new(:config, :mutation)

      # Return mutation
      #
      # @return [Mutation]
      #
      # @api private
      #
      attr_reader :mutation

      # Initialize object
      #
      # @param [Config] config
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

      # Return killer instance
      #
      # @return [Killer]
      #
      # @api private
      #
      attr_reader :killer

      # Test if mutation was handeled successfully
      #
      # @return [true]
      #   if successful
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def success?
        mutation.success?(killer)
      end

    private

      # Perform operation
      #
      # @return [undefined]
      #
      # @api private
      #
      def run
        @killer = config.strategy.kill(mutation)
      end

    end
  end
end
