# frozen_string_literal: true

module Mutant
  class Reporter
    # Reporter that reports in human readable format
    class CLI < self
      include Anima.new(:print_warnings, :output, :format)

      # Build reporter
      #
      # @param [IO] output
      #
      # @return [Reporter::CLI]
      def self.build(output)
        new(
          format:         Format::Progressive.new(tty: output.respond_to?(:tty?) && output.tty?),
          print_warnings: false,
          output:
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

      # Report test start
      #
      # @param [Env] env
      #
      # @return [self]
      def test_start(env)
        write(format.test_start(env))
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

      # Report progress object
      #
      # @return [self]
      def test_progress(status)
        write(format.test_progress(status))
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
        output.puts(message) if print_warnings
        self
      end

      # Report env
      #
      # @param [Result::Env] env
      #
      # @return [self]
      def report(env)
        finish_progress_bar
        Printer::EnvResult.call(output:, object: env)
        self
      end

      # Report env
      #
      # @param [Result::Env] env
      #
      # @return [self]
      def test_report(env)
        finish_progress_bar
        Printer::Test::EnvResult.call(output:, object: env)
        self
      end

    private

      def write(frame)
        output.write(frame)
      end

      def finish_progress_bar
        output.puts if format.tty
      end

    end # CLI
  end # Reporter
end # Mutant
