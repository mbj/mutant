# frozen_string_literal: true

require 'io/console'

module Mutant
  class Reporter
    class CLI
      # CLI output format
      #
      # rubocop:disable Style/FormatString
      class Format
        include AbstractType, Anima.new(:tty, :output_io)

        DEFAULT_TERMINAL_WIDTH = 80

        # Dynamic terminal width - queries current size on each call
        #
        # @return [Integer]
        def terminal_width
          return DEFAULT_TERMINAL_WIDTH unless tty && output_io.respond_to?(:winsize)

          output_io.winsize.last
        rescue Errno::ENOTTY, Errno::EOPNOTSUPP
          DEFAULT_TERMINAL_WIDTH
        end

        # Start representation
        #
        # @param [Env] env
        #
        # @return [String]
        abstract_method :start

        # Progress representation
        #
        # @return [String]
        abstract_method :progress

        # Progress representation
        #
        # @return [String]
        abstract_method :test_progress

        # Report delay in seconds
        #
        # @return [Float]
        def delay = self.class::REPORT_DELAY

        # Output abstraction to decouple tty? from buffer
        class Output
          include Anima.new(:tty, :buffer, :terminal_width)

          # Test if output is a tty
          #
          # @return [Boolean]
          alias_method :tty?, :tty
          public :tty?

          %i[puts write].each do |name|
            define_method(name) do |*args, &block|
              buffer.public_send(name, *args, &block)
            end
          end
        end # Output

      private

        def format(printer, object)
          buffer = new_buffer
          printer.call(output: Output.new(tty:, buffer:, terminal_width:), object:)
          buffer.rewind
          buffer.read
        end

        # Format for progressive non rewindable output
        class Progressive < self

          REPORT_FREQUENCY = 1.0
          REPORT_DELAY     = 1 / REPORT_FREQUENCY

          # ANSI escape sequences
          CLEAR_LINE  = "\e[2K"
          CURSOR_UP   = "\e[A"
          CURSOR_DOWN = "\e[B"

          # Pattern to strip ANSI escape codes for visual length calculation
          ANSI_ESCAPE = /\e\[[0-9;]*[A-Za-z]/

          # Start representation
          #
          # @return [String]
          def start(env)
            format(Printer::Env, env)
          end

          # Test start representation
          #
          # @return [String]
          def test_start(env)
            format(Printer::Test::Env, env)
          end

          # Progress representation
          #
          # @return [String]
          def progress(status)
            wrap_progress { format(status_progressive_printer, status) }
          end

          # Progress representation
          #
          # @return [String]
          def test_progress(status)
            wrap_progress { format(test_status_progressive_printer, status) }
          end

        private

          def new_buffer = StringIO.new

          def status_progressive_printer = tty ? Printer::StatusProgressive::Tty : Printer::StatusProgressive::Pipe

          def test_status_progressive_printer = tty ? Printer::Test::StatusProgressive::Tty : Printer::Test::StatusProgressive::Pipe

          # Wrap progress output with TTY-specific line handling
          #
          # Uses indicatif-style multi-line clearing to handle terminal resize:
          # 1. Calculate how many visual lines previous content spans at current width
          # 2. Clear all those lines using cursor movement
          # 3. Write new content
          #
          # @return [String]
          def wrap_progress
            content = yield
            return content unless tty

            clear_seq            = clear_last_lines(visual_lines_at_width(@last_content_length, terminal_width))
            @last_content_length = visual_length(content)

            "#{clear_seq}#{content}"
          end

          # Calculate visual length of string (excluding ANSI escape sequences)
          #
          # @param string [String]
          # @return [Integer]
          def visual_length(string)
            string.gsub(ANSI_ESCAPE, '').length
          end

          # Calculate visual lines content occupies at given terminal width
          #
          # @param content_length [Integer, nil]
          # @param width [Integer]
          # @return [Integer]
          def visual_lines_at_width(content_length, width)
            return 1 if width < 1

            # nil.to_f = 0.0, and ceil(0.0/w).clamp(1,10) = 1
            (content_length.to_f / width).ceil.clamp(1, 10)
          end

          # Build escape sequence to clear n lines (indicatif/console pattern)
          #
          # Algorithm from console crate's clear_last_lines:
          # 1. Move cursor up (n-1) lines to reach top
          # 2. For each line: clear it, move down (except last)
          # 3. Move cursor back up (n-1) lines
          #
          # For n=1: produces "\r\e[2K" (no cursor movement needed)
          # For n>1: moves up, clears each line with downs between, moves back up
          #
          # @param lines [Integer] number of lines to clear (must be >= 1)
          # @return [String]
          def clear_last_lines(lines)
            buffer = StringIO.new
            buffer << (CURSOR_UP * (lines - 1))
            lines.times do |i|
              buffer << "\r" << CLEAR_LINE
              buffer << CURSOR_DOWN if i < lines - 1
            end
            buffer << (CURSOR_UP * (lines - 1))
            buffer.string
          end

        end # Progressive
      end # Format
    end # CLI
  end # Reporter
end # Mutant
