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
        tput = Tput.detect
        tty = output.respond_to?(:tty?) && output.tty?
        format = if !Mutant.ci? && tty && tput
          Format::Framed.new(tty:  tty, tput: tput)
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

      # Report progress object
      #
      # @param [Parallel::Status] status
      #
      # @return [self]
      #
      # @api private
      #
      def progress(status)
        write(format.progress(status))
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

      # Report env
      #
      # @param [Result::Env] env
      #
      # @return [self]
      #
      # @api private
      #
      def report(env)
        Printer::EnvResult.run(output, env)
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
