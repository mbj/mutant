module Mutant
  class Mutation
    # Neutral mutation
    class Neutral < self

      SYMBOL = 'neutral'

      # Noop mutation, special case of neutral
      class Noop < self

        SYMBOL = 'noop'

      end

      # Return identification
      #
      # @return [String]
      #
      # @api private
      #
      def identification
        "#{self.class::SYMBOL}:#{super}"
      end
      memoize :identification

      # Test if killer is successful
      #
      # @param [Killer] killer
      #
      # @return [true]
      #   if killer did NOT killed mutation
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def success?(killer)
        !killer.killed?
      end

    end # Neutral
  end # Mutation
end # Mutant
