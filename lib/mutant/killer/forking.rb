module Mutant
  class Killer

    # A killer that executes other killer in forked environemnts
    class Forking < self
      include Equalizer.new(:killer)

      # Return killer
      #
      # @return [Killer]
      #
      # @api private
      #
      attr_reader :killer

      # Initalize killer
      #
      # @param [Killer] killer
      #   the killer that will be used
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(killer)
        @killer = killer
      end

      # Return killer instance
      #
      # @param [Strategy] strategy
      # @param [Mutation] mutation
      #
      # @return [Killer::Forked]
      #
      # @api private
      #
      def new(strategy, mutation)
        Forked.new(killer, strategy, mutation)
      end

    end # Forking
  end # Killer
end # Mutant
