module Mutant
  class Reporter
    # Reporter that reports in human readable format
    class CLI < self
      include Concord::Public.new(:output)

      NL = "\n".freeze

      # Report object
      #
      # @param [Object] object
      #
      # @return [self]
      #
      # @api private
      #
      def report(object)
        Printer.visit(object, output)
        self
      end

    end # CLI
  end # Reporter
end # Mutant
