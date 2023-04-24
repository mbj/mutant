# frozen_string_literal: true

module Mutant
  class Reporter
    # Reporter that reports in human readable format
    class CLI < self
      include Anima.new(:output, :format)

      # Build reporter
      #
      # @param [IO] output
      #
      # @return [Reporter::CLI]
      def self.build(output)
        new(
          format: Format::Progressive.new(tty: output.respond_to?(:tty?) && output.tty?),
          output: output
        )
      end

      # Report start
      #
      # @param [Env] env
      #
      # @return [self]
      def start(env)
        write(format.start(env))
        self
      end

      # Report progress object
      #
      # @param [Parallel::Status] status
      #
      # @return [self]
      def progress(status)
        write(format.progress(status))
        self
      end

      # Report delay in seconds
      #
      # @return [Float]
      def delay
        format.delay
      end

      # Report warning
      #
      # @param [String] message
      #
      # @return [self]
      def warn(message)
        output.puts(message)
        self
      end

      # Report env
      #
      # @param [Result::Env] env
      #
      # @return [self]
      def report(env)
        Printer::EnvResult.call(output: output, object: env)
        self
      end

    private

      def write(frame)
        output.write(frame)
      end

    end # CLI
  end # Reporter
end # Mutant
