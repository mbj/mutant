module Mutant
  class Killer
    # Abstract base class for killer with static result
    class Static < self

      # Return result
      #
      # @return [true]
      #   if mutation was killed
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def run
        self.class::RESULT
      end

      # Killer that is always successful
      class Success < self
        RESULT = true
      end

      # Killer that always fails
      class Fail < self
        RESULT = false
      end
    end
  end
end
