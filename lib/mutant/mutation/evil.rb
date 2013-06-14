module Mutant
  class Mutation
    # Evul mutation
    class Evil < self

      # Return identification
      #
      # @return [String]
      #
      # @api private
      #
      def identification
        "evil:#{super}"
      end
      memoize :identification

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
