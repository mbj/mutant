# encoding: utf-8

module Mutant
  class Mutation
    # Evul mutation
    class Evil < self

      SHOULD_FAIL = true
      SYMBOL      = 'evil'.freeze

      # Test if killer is successful
      #
      # @param [Killer] killer
      #
      # @return [true]
      #   if killer killed mutation
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def success?(killer)
        killer.killed?
      end

    end # Evil
  end # Mutation
end # Mutant
