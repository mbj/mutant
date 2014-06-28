module Mutant
  class Reporter
    # Reporter to trace report calls, used as a spec adapter
    class Trace
      include Concord::Public.new(:progress_calls, :report_calls)

      # Return new trace reporter
      #
      # @return [Tracer]
      #
      # @api private
      #
      def self.new
        super([], [])
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
        report_calls << object
        self
      end

      # Report new progress on object
      #
      # @param [Object] object
      #
      # @return [self]
      #
      # @api private
      #
      def progress(object)
        progress_calls << object
        self
      end

    end # Tracker
  end # reporter
end # Mutant
