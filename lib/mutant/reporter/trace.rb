module Mutant
  class Reporter
    # Reporter to trace report calls, used as a spec adapter
    class Trace
      include Adamantium::Mutable, Anima.new(:progress_calls, :report_calls, :warn_calls)

      # Return new trace reporter
      #
      # @return [Trace]
      #
      # @api private
      #
      def self.new
        super(Hash[anima.attribute_names.map { |name| [name, []] }])
      end

      # Warn with message
      #
      # @param [String] message
      #
      # @return [self]
      #
      # @api private
      #
      def warn(message)
        warn_calls << message
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
