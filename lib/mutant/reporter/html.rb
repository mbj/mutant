# encoding: utf-8

module Mutant
  class Reporter
    # Reporter that reports in human readable format
    class HTML < self
      include Concord.new(:output)

      # HTML Progress object. This does nothing for HTML.
      #
      # @param [Object] object
      #
      # @return [self]
      #
      # @api private
      #
      def progress(_)
        self
      end

      # HTML Report object
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

    end # HTML
  end # Reporter
end # Mutant
