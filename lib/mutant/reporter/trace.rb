module Mutant
  class Reporter
    # Reporter to trace report calls, used as a spec adapter
    class Trace
      include Adamantium::Mutable, Anima.new(
        :progress_calls,
        :report_calls,
        :start_calls,
        :warn_calls
      )

      # New trace reporter
      #
      # @return [Trace]
      def self.new
        super(Hash[anima.attribute_names.map { |name| [name, []] }])
      end

      %i[progress report start warn].each do |name|
        define_method(name) do |object|
          public_send(:"#{name}_calls") << object
          self
        end
      end

      REPORT_DELAY = 0.0

      # Report delay
      #
      # @return [Float]
      def delay
        REPORT_DELAY
      end

    end # Tracker
  end # reporter
end # Mutant
