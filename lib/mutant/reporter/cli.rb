module Mutant
  class Reporter
    # Reporter that reports in human readable format
    class CLI < self
      include Concord.new(:output)

      NL = "\n".freeze
      CLEAR_PREV_LINE = "\e[1A\e[2K".freeze

      # Output abstraction to decouple tty? from buffer
      class Output
        include Concord.new(:tty, :buffer)

        # Test if output is a tty
        #
        # @return [Boolean]
        #
        # @api private
        #
        def tty?
          @tty
        end

        [:puts, :write].each do |name|
          define_method(name) do |*args, &block|
            buffer.public_send(name, *args, &block)
          end
        end

      end # Output

      # Rate per second progress report fires
      OUTPUT_RATE = 1.0 / 20

      # Initialize object
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(*)
        super
        @last_frame = nil
        @last_length = 0
        @tty = output.respond_to?(:tty?) && output.tty?
      end

      # Report progress object
      #
      # @param [Runner::Collector] collector
      #
      # @return [self]
      #
      # @api private
      #
      def progress(collector)
        throttle do
          swap(frame(Printer::Collector, collector))
        end

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

      # Report env
      #
      # @param [Result::Env] env
      #
      # @return [self]
      #
      # @api private
      #
      def report(env)
        swap(frame(Printer::EnvResult, env))
        self
      end

    private

      # Compute progress frame
      #
      # @return [String]
      #
      # @api private
      #
      def frame(reporter, object)
        buffer = StringIO.new
        buffer.write(clear_command) if @tty
        reporter.run(Output.new(@tty, buffer), object)
        buffer.rewind
        buffer.read
      end

      # Swap output frame
      #
      # @param [String] frame
      #
      # @return [undefined]
      #
      # @api private
      #
      def swap(frame)
        output.write(frame)
        @last_length = frame.split(NL).length
      end

      # Call block throttled
      #
      # @return [undefined]
      #
      # @api private
      #
      def throttle
        now = Time.now
        return if @last_frame && (now - @last_frame) < OUTPUT_RATE
        yield
        @last_frame = now
      end

      # Return clear command for last frame length
      #
      # @return [String]
      #
      # @api private
      #
      def clear_command
        CLEAR_PREV_LINE * @last_length
      end

    end # CLI
  end # Reporter
end # Mutant
