module Mutant
  class Mutation
    # Neutral mutation
    class Neutral < self

      SYMBOL = 'neutral'

      # Noop mutation, special case of neutral
      class Noop < self

        SYMBOL = 'noop'

        # Indicate if a killer should treat a kill as problematic
        #
        # @return [false] Killing noop mutants is a serious problem. Failures
        #   in noop may indicate a broken test suite, but they can also be an
        #   indication  mutant has altered the runtime environment in a subtle
        #   way and tickled an odd bug
        #
        # @api private
        #
        def should_survive?
          false
        end

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

      # Indicate if a killer should treat a kill as problematic
      #
      # @return [true] Neutral mutants must die
      #
      # @api private
      #
      def should_survive?
        false
      end

    end # Neutral
  end # Mutation
end # Mutant
