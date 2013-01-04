module Mutant
  class Reporter

    # Null reporter
    class Null < self

      # Report subject
      #
      # @param [Subject] subject
      #
      # @return [self]
      #
      # @api private
      #
      def subject(*)
        self
      end

      # Report mutation
      #
      # @param [Mutation] mutation
      #
      # @return [self]
      #
      # @api private
      #
      def mutation(*)
        self
      end

      # Report killer
      #
      # @param [Killer] killer
      #
      # @return [self]
      #
      # @api private
      #
      def killer(*)
        self
      end
    end

  end
end
