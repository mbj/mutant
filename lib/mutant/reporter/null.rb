module Mutant
  class Reporter

    # Null reporter
    class Null < self

      # Report object
      #
      # @param [Object] _object
      #
      # @return [self]
      #
      # @api private
      #
      def report(_object)
        self
      end

    end # Null
  end # Reporter
end # Mutant
