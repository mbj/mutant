# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Format::Progressive do
  setup_shared_context

  let(:output_io) { instance_double(IO, winsize: [24, initial_width]) }
  let(:initial_width) { 80 }
  let(:format) { described_class.new(tty: tty?, output_io:) }

  # Constants for escape sequences
  let(:clear_line)  { "\e[2K" }
  let(:cursor_up)   { "\e[A" }
  let(:cursor_down) { "\e[B" }

  # Test status for test_progress tests
  let(:test_env_result) do
    Mutant::Result::TestEnv.new(
      env:,
      runtime:      1.0,
      test_results: []
    )
  end

  let(:test_status) do
    Mutant::Parallel::Status.new(
      active_jobs: 1,
      done:        false,
      payload:     test_env_result
    )
  end

  describe '#progress' do
    subject { format.progress(status) }

    with(:env_result) { { subject_results: [] } }

    context 'when tty is false' do
      let(:tty?) { false }

      it 'returns content without escape sequences' do
        expect(subject).to match(/^progress:.*\n$/)
        expect(subject).not_to include("\e")
      end
    end

    context 'when tty is true' do
      let(:tty?) { true }

      it 'prefixes with simple clear on first call' do
        expect(subject).to start_with("\r#{clear_line}")
        expect(subject).not_to include(cursor_up)
      end

      it 'includes progress content after clear sequence' do
        # Verify content is present, not just clear sequences
        expect(subject).to include('RUNNING')
        expect(subject).to include('alive:')
      end

      it 'passes tty to Output for printer colorization' do
        # Format#format passes tty: to Output.new, which the printer uses for colorize
        # If mutated to tty: nil, colorize won't add color codes
        expect(subject).to include("\e[32m") # Green color code
      end

      context 'on subsequent calls with same terminal width' do
        before { format.progress(status) }

        it 'uses single-line clear (no cursor movement)' do
          result = format.progress(status)
          expect(result).to start_with("\r#{clear_line}")
          expect(result).not_to include(cursor_up)
        end
      end

      context 'when terminal shrinks causing 3-line wrap' do
        # Content is ~82 chars (bar maxes at 40 + ~42 for other text)
        # At width 28: ceil(82/28) = 3 lines
        let(:initial_width) { 100 }

        before do
          format.progress(status)
          allow(output_io).to receive(:winsize).and_return([24, 28])
        end

        it 'generates exact 3-line clear sequence' do
          result = format.progress(status)
          # Expected: up 2, clear+down x2, clear, up 2
          expected_prefix = [
            cursor_up * 2,
            "\r#{clear_line}#{cursor_down}",
            "\r#{clear_line}#{cursor_down}",
            "\r#{clear_line}",
            cursor_up * 2
          ].join
          expect(result).to start_with(expected_prefix)
        end
      end

      context 'when terminal shrinks causing 4-line wrap' do
        # Content is ~82 chars. At width 21: ceil(82/21) = 4 lines
        let(:initial_width) { 120 }

        before do
          format.progress(status)
          allow(output_io).to receive(:winsize).and_return([24, 21])
        end

        it 'generates exact 4-line clear sequence' do
          result = format.progress(status)
          # Expected: up 3, clear+down x3, clear, up 3
          expected_prefix = [
            cursor_up * 3,
            "\r#{clear_line}#{cursor_down}",
            "\r#{clear_line}#{cursor_down}",
            "\r#{clear_line}#{cursor_down}",
            "\r#{clear_line}",
            cursor_up * 3
          ].join
          expect(result).to start_with(expected_prefix)
        end
      end

      context 'when terminal shrinks significantly' do
        # Content is ~82 chars. At width 17: ceil(82/17) = 5 lines
        let(:initial_width) { 120 }

        before do
          format.progress(status)
          allow(output_io).to receive(:winsize).and_return([24, 17])
        end

        it 'generates exact 5-line clear sequence' do
          result = format.progress(status)
          # Expected: up 4, clear+down x4, clear, up 4
          expected_prefix = [
            cursor_up * 4,
            "\r#{clear_line}#{cursor_down}",
            "\r#{clear_line}#{cursor_down}",
            "\r#{clear_line}#{cursor_down}",
            "\r#{clear_line}#{cursor_down}",
            "\r#{clear_line}",
            cursor_up * 4
          ].join
          expect(result).to start_with(expected_prefix)
        end
      end
    end
  end

  describe '#visual_lines_at_width (via progress)' do
    let(:tty?) { true }

    context 'with nil content_length (first call)' do
      it 'returns 1 line (simple clear only)' do
        result = format.progress(status)
        expect(result).to start_with("\r#{clear_line}")
        expect(result).not_to include(cursor_up)
      end
    end

    context 'with width < 1' do
      before do
        format.progress(status)
        allow(output_io).to receive(:winsize).and_return([24, 0])
      end

      it 'clamps to 1 line (avoids division by zero)' do
        result = format.progress(status)
        expect(result).to start_with("\r#{clear_line}")
        expect(result).not_to include(cursor_up)
      end
    end

    context 'with width of 1' do
      before do
        format.progress(status)
        allow(output_io).to receive(:winsize).and_return([24, 1])
      end

      it 'clamps to max 10 lines' do
        result = format.progress(status)
        # With 80 chars at width 1 = 80 lines, but clamped to 10
        expect(result.scan(cursor_up).length).to eq(9 + 9) # 9 up at start, 9 up at end
      end
    end

    context 'ceil is required for fractional line counts' do
      # Content ~82 chars. At width 55: 82/55 = 1.49
      # With ceil: ceil(1.49) = 2 lines
      # Without ceil: 1.49.clamp(1,10) = 1.49 (not an integer, would fail in times)
      let(:initial_width) { 100 }

      before do
        format.progress(status)
        allow(output_io).to receive(:winsize).and_return([24, 55])
      end

      it 'rounds up fractional content/width to integer lines' do
        result = format.progress(status)
        # Must be 2 lines: up 1, clear+down, clear, up 1
        expected_2_line = [
          cursor_up,
          "\r#{clear_line}#{cursor_down}",
          "\r#{clear_line}",
          cursor_up
        ].join
        expect(result).to start_with(expected_2_line)
      end
    end

    context 'division by width is required' do
      # Content ~82 chars. At width 42: 82/42 = 1.95, ceil = 2
      # Without /width: ceil(82.0).clamp(1,10) = 10 (wrong)
      let(:initial_width) { 100 }

      before do
        format.progress(status)
        allow(output_io).to receive(:winsize).and_return([24, 42])
      end

      it 'divides content length by width to get line count' do
        result = format.progress(status)
        # Must be 2 lines (not 10), proving division happened
        expected_2_line = [
          cursor_up,
          "\r#{clear_line}#{cursor_down}",
          "\r#{clear_line}",
          cursor_up
        ].join
        expect(result).to start_with(expected_2_line)
      end
    end
  end

  describe '#clear_last_lines (via progress)' do
    let(:tty?) { true }

    context 'when lines == 1' do
      before { format.progress(status) }

      it 'returns simple clear sequence' do
        result = format.progress(status)
        expect(result).to start_with("\r#{clear_line}")
        expect(result).not_to include(cursor_up)
        expect(result).not_to include(cursor_down)
      end
    end

    context 'when lines == 2' do
      # Content ~82 chars. At width 42: ceil(82/42) = 2 lines
      let(:initial_width) { 100 }

      before do
        format.progress(status)
        allow(output_io).to receive(:winsize).and_return([24, 42])
      end

      it 'builds exact 2-line clear sequence' do
        result = format.progress(status)
        # lines=2: up 1, (clear, down), clear, up 1
        expected_clear = [
          cursor_up, # move up 1
          "\r#{clear_line}#{cursor_down}", # clear line 1, move down
          "\r#{clear_line}", # clear line 2
          cursor_up # move back up 1
        ].join
        expect(result).to start_with(expected_clear)
      end
    end

    context 'when lines == 3' do
      # Content ~82 chars. At width 28: ceil(82/28) = 3 lines
      let(:initial_width) { 100 }

      before do
        format.progress(status)
        allow(output_io).to receive(:winsize).and_return([24, 28])
      end

      it 'builds exact 3-line clear sequence' do
        result = format.progress(status)
        # lines=3: up 2, (clear, down) x2, clear, up 2
        expected_clear = [
          cursor_up * 2,
          "\r#{clear_line}#{cursor_down}",
          "\r#{clear_line}#{cursor_down}",
          "\r#{clear_line}",
          cursor_up * 2
        ].join
        expect(result).to start_with(expected_clear)
      end
    end
  end

  describe '#visual_length (via progress)' do
    let(:tty?) { true }

    context 'with content containing ANSI codes' do
      before { format.progress(status) }

      it 'calculates length excluding ANSI codes for same-width case' do
        # Second call with same width should use single-line clear
        result = format.progress(status)
        expect(result).to start_with("\r#{clear_line}")
        expect(result).not_to include(cursor_up)
      end

      it 'correctly affects line calculation when terminal shrinks' do
        # Content is ~82 visual chars (ignoring ANSI codes which add ~9 bytes)
        # If visual_length incorrectly included ANSI codes (~91 bytes),
        # at width 46, it would be ceil(91/46)=2 lines instead of ceil(82/46)=2
        # But at width 43, with ANSI: ceil(91/43)=3, without: ceil(82/43)=2
        # So we use width 43 to distinguish correct vs incorrect behavior
        allow(output_io).to receive(:winsize).and_return([24, 43])
        result = format.progress(status)

        # If visual_length works correctly (82 chars), at width 43 = 2 lines
        # 2 lines: up 1, clear+down, clear, up 1
        expected_2_line = [
          cursor_up,
          "\r#{clear_line}#{cursor_down}",
          "\r#{clear_line}",
          cursor_up
        ].join
        expect(result).to start_with(expected_2_line)
      end
    end

    context 'when visual_length return value affects line count' do
      # This test ensures visual_length returns an Integer that affects calculations
      # Content is ~82 visual chars. At width 28: ceil(82/28) = 3 lines
      # If visual_length returned nil, visual_lines_at_width would return 1
      let(:initial_width) { 100 }

      before do
        format.progress(status)
        allow(output_io).to receive(:winsize).and_return([24, 28])
      end

      it 'produces multi-line clear proving visual_length returns a meaningful value' do
        result = format.progress(status)
        # Must have cursor movement, proving visual_length returned something > 28
        expect(result).to include(cursor_up)
        expect(result.scan(cursor_up).length).to be >= 4 # 2 at start + 2 at end
      end
    end
  end

  describe '#test_progress' do
    subject { format.test_progress(test_status) }

    context 'when tty is false' do
      let(:tty?) { false }

      it 'returns content without escape sequences' do
        expect(subject).to match(/^progress:.*\n$/)
        expect(subject).not_to include("\e")
      end
    end

    context 'when tty is true' do
      let(:tty?) { true }

      it 'prefixes with simple clear on first call' do
        expect(subject).to start_with("\r#{clear_line}")
        expect(subject).not_to include(cursor_up)
      end

      it 'includes test progress content after clear sequence' do
        expect(subject).to include('TESTING')
        expect(subject).to include('failed:')
      end

      it 'passes tty to Output for printer colorization' do
        # Format#format passes tty: to Output.new, which the printer uses for colorize
        # If mutated to tty: nil, colorize won't add color codes
        expect(subject).to include("\e[32m") # Green color code
      end

      context 'on subsequent calls with same terminal width' do
        before { format.test_progress(test_status) }

        it 'uses single-line clear (no cursor movement)' do
          result = format.test_progress(test_status)
          expect(result).to start_with("\r#{clear_line}")
          expect(result).not_to include(cursor_up)
        end
      end

      context 'when terminal shrinks causing multi-line wrap' do
        let(:initial_width) { 100 }

        before do
          format.test_progress(test_status)
          allow(output_io).to receive(:winsize).and_return([24, 28])
        end

        it 'generates multi-line clear sequence' do
          result = format.test_progress(test_status)
          expect(result).to include(cursor_up)
          expect(result).to include(clear_line)
        end
      end
    end
  end

  describe '#terminal_width' do
    context 'when tty is true and output_io responds to winsize' do
      let(:tty?) { true }

      it 'returns the terminal width from winsize' do
        expect(format.terminal_width).to eq(initial_width)
      end

      it 'queries winsize dynamically' do
        expect(format.terminal_width).to eq(80)
        allow(output_io).to receive(:winsize).and_return([24, 120])
        expect(format.terminal_width).to eq(120)
      end
    end

    context 'when tty is false' do
      let(:tty?) { false }

      it 'returns DEFAULT_TERMINAL_WIDTH' do
        expect(format.terminal_width).to eq(80)
      end

      it 'does not call winsize' do
        format.terminal_width
        expect(output_io).not_to have_received(:winsize) if output_io.respond_to?(:winsize)
      end
    end

    context 'when output_io does not respond to winsize' do
      let(:tty?) { true }
      let(:output_io) { instance_double(IO) }

      before do
        allow(output_io).to receive(:respond_to?).with(:winsize).and_return(false)
      end

      it 'returns DEFAULT_TERMINAL_WIDTH' do
        expect(format.terminal_width).to eq(80)
      end
    end

    context 'when winsize raises Errno::ENOTTY' do
      let(:tty?) { true }

      before do
        allow(output_io).to receive(:winsize).and_raise(Errno::ENOTTY)
      end

      it 'returns DEFAULT_TERMINAL_WIDTH' do
        expect(format.terminal_width).to eq(80)
      end
    end

    context 'when winsize raises Errno::EOPNOTSUPP' do
      let(:tty?) { true }

      before do
        allow(output_io).to receive(:winsize).and_raise(Errno::EOPNOTSUPP)
      end

      it 'returns DEFAULT_TERMINAL_WIDTH' do
        expect(format.terminal_width).to eq(80)
      end
    end
  end
end
