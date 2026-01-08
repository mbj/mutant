# frozen_string_literal: true

module Mutant
  class Reporter
    # Reporter that reports in human readable format
    class CLI < self
      include Anima.new(:print_warnings, :output, :format)

      DEFAULT_TERMINAL_WIDTH = 80

      # Build reporter
      #
      # @param [IO] output
      #
      # @return [Reporter::CLI]
      def self.build(output)
        tty = output.respond_to?(:tty?) && output.tty?
        terminal_width = tty ? detect_terminal_width(output) : DEFAULT_TERMINAL_WIDTH

        new(
          format:         Format::Progressive.new(tty:, terminal_width:),
          print_warnings: false,
          output:
        )
      end

      def self.detect_terminal_width(output)
        output.winsize.last
      rescue Errno::ENOTTY, Errno::EOPNOTSUPP
        DEFAULT_TERMINAL_WIDTH
      end
      private_class_method :detect_terminal_width

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
