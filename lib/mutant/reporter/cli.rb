# encoding: utf-8

module Mutant
  class Reporter
    # Reporter that reports in human readable format
    class CLI < self
      include Concord.new(:output)

      NL = "\n".freeze

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
