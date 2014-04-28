# encoding: utf-8

module Mutant
  class Runner
    # Mutation runner
    class Mutation < self
      include Equalizer.new(:config, :mutation)

      register Mutant::Mutation

      # Return mutation
      #
      # @return [Mutation]
      #
      # @api private
      #
      attr_reader :mutation

      # Return killers
      #
      # @return [Killer]
      #
      # @api private
      #
      attr_reader :killers

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
        killers.any?(&:success?)
      end

    private

      # Perform operation
      #
      # @return [undefined]
      #
      # @api private
      #
      def run
        @killers = dispatch(config.strategy.killers(mutation))
        report(self)
      end

    end # Mutation
  end # Runner
end # Mutant
