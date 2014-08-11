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
        format =
          if !Mutant.ci? && tty && Tput::INSTANCE.available
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
      # @api private
      #
      def start(env)
        write(format.start(env))
        self
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
        write(format.progress(collector))

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
        write(format.report(env))
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
