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
        tty = output.respond_to?(:tty?) && output.tty?

        new(
          format:         Format::Progressive.new(tty:, output_io: output),
          print_warnings: false,
          output:
        )
      end

      # Report start
      #
      # @param [Env] env
      #
      # @return [self]
      def start(env) = tap { write(format.start(env)) }

      # Report test start
      #
      # @param [Env] env
      #
      # @return [self]
      def test_start(env) = tap { write(format.test_start(env)) }

      # Report progress object
      #
      # @param [Parallel::Status] status
      #
      # @return [self]
      def progress(status) = tap { write(format.progress(status)) }

      # Report progress object
      #
      # @return [self]
      def test_progress(status) = tap { write(format.test_progress(status)) }

      # Report delay in seconds
      #
      # @return [Float]
      def delay = format.delay

      # Report warning
      #
      # @param [String] message
      #
      # @return [self]
      def warn(message) = tap { output.puts(message) if print_warnings }

      # Report env
      #
      # @param [Result::Env] env
      #
      # @return [self]
      def report(env)
        write_final_progress(env)
        Printer::EnvResult.call(output:, object: env)
        self
      end

      # Report env
      #
      # @param [Result::Env] env
      #
      # @return [self]
      def test_report(env)
        write_final_test_progress(env)
        Printer::Test::EnvResult.call(output:, object: env)
        self
      end

    private

      def write(frame)
        output.write(frame)
      end

      def write_final_progress(env)
        return unless format.tty

        final_status = Parallel::Status.new(
          active_jobs: Set.new,
          done:        true,
          payload:     env
        )
        write(format.progress(final_status))
        output.puts
      end

      def write_final_test_progress(env)
        return unless format.tty

        final_status = Parallel::Status.new(
          active_jobs: Set.new,
          done:        true,
          payload:     env
        )
        write(format.test_progress(final_status))
        output.puts
      end

    end # CLI
  end # Reporter
end # Mutant
