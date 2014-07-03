module Mutant
  class Reporter
    # Reporter that reports in human readable format
    class CLI < self
      include Concord.new(:output)

      # Report progress object
      #
      # @param [Object] object
      #
      # @return [self]
      #
      # @api private
      #
      def progress(object)
        Progress.run(output, object)
        self
      end

      # Report warning
      #
      # @param [String] message
      #
      # @return [self]
      #
      # @api private
      #
      def warn(message)
        output.puts(message)
        self
      end

      # Report object
      #
      # @param [Object] object
      #
      # @return [self]
      #
      # @api private
      #
      def report(object)
        Report.run(output, object)
        self
      end

    end # CLI
  end # Reporter
end # Mutant
