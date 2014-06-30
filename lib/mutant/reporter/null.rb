module Mutant
  class Reporter

    # Null reporter
    class Null < self
      include Equalizer.new

      # Write warning message
      #
      # @param [String] _message
      #
      # @return [self]
      #
      # @api private
      #
      def warn(_message)
        self
      end

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

      # Report progress on object
      #
      # @param [Object] _object
      #
      # @return [self]
      #
      # @api private
      #
      def progress(_object)
        self
      end

    end # Null
  end # Reporter
end # Mutant
