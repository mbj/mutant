module Mutant
  class Reporter
    # Reporter that reports in human readable format
    class CLI < self
      include Concord.new(:output, :format)

      # Build reporter
      #
      # @param [IO] output
      #
      # @return [Reporter::CLI]
      #
      # @api private
      #
      def self.build(output)
        tty = output.respond_to?(:tty?) && output.tty?
        format = if !Mutant.ci? && tty && Tput::INSTANCE.available
          Format::Framed.new(tty:  tty, tput: Tput::INSTANCE)
        else
          Format::Progressive.new(tty: tty)
        end
        new(output, format)
      end

      # Report start
      #
      # @param [Env] env
      #
      # @return [self]
      #
      # @api private
      #
      def start(env)
        write(format.start(env))
        self
      end

      %i[trace_status kill_status].each do |name|
        define_method(name) do |argument|
          write(format.public_send(name, argument))
        end
      end

      # Report kills
      #
      # @param [Result::Env] env
      #
      # @return [self]
      #
      # @api private
      #
      def kill_report(env)
        Printer::Report::Kill.run(output, env)
        self
      end

      # Report trace
      #
      # @param [Result::EnvTrace] env
      #
      # @return [self]
      #
      # @api private
      #
      def trace_report(env)
        Printer::Report::Trace.run(output, env)
        self
      end

      # Return report delay in seconds
      #
      # TODO: Move this to a callback registration
      #
      #   Reporters other than CLI that might exist in future
      #   may only need the final report. So providing a noop callback
      #   registration makes more sense for these.
      #   As only CLI reporters exist currently I do not really care right now.
      #
      # @return [Float]
      #
      # @api private
      #
      def delay
        format.delay
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

    private

      # Write output frame
      #
      # @param [String] frame
      #
      # @return [undefined]
      #
      # @api private
      #
      def write(frame)
        output.write(frame)
      end

    end # CLI
  end # Reporter
end # Mutant
