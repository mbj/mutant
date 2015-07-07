module Mutant
  class Reporter
    # Reporter to trace report calls, used as a spec adapter
    class Trace
      include Adamantium::Mutable, Anima.new(:start_calls, :progress_calls, :report_calls, :warn_calls)

      # New trace reporter
      #
      # @return [Trace]
      #
      # @api private
      def self.new
        super(Hash[anima.attribute_names.map { |name| [name, []] }])
      end

      %w[start progress report warn].each do |name|
        define_method(name) do |object|
          public_send(:"#{name}_calls") << object
          self
        end
      end

      REPORT_DELAY = 0.0

      # Report delay
      #
      # @return [Float]
      #
      # @api private
      def delay
        REPORT_DELAY
      end

    end # Tracker
  end # reporter
end # Mutant
