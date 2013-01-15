module Mutant
  class Mutation
    # Neutral mutation
    class Neutral < self

      # Return identification
      #
      # @return [String]
      #
      # @api private
      #
      def identification
        "noop:#{super}"
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

    end
  end
end
