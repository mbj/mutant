# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI do
  setup_shared_context

  let(:format) { described_class::Format::Progressive.new(tty: tty?, output_io:) }
  let(:object) { described_class.new(format:, output:, print_warnings: false) }
  let(:tty?)      { false }
  let(:output_io) { output }

  def contents
    output.rewind
    output.read
  end

  def self.it_reports(expected_content)
    it 'writes expected report to output' do
      expect(subject).to be(object)
      expect(contents).to eql(expected_content)
    end
  end

  describe '.build' do
    subject { described_class.build(output) }

    context 'when output is a tty' do
      let(:tty?)   { true }
      let(:output) { instance_double(IO, tty?: true, winsize: [24, 80]) }

      it { should eql(described_class.new(format:, output:, print_warnings: false)) }
    end

    context 'when output is not a tty' do
      context 'and does not respond to #tty?' do
        let(:output) { nil }

        it { should eql(described_class.new(format:, output:, print_warnings: false)) }
      end

      context 'and does respond to #tty?' do
        it { should eql(described_class.new(format:, output:, print_warnings: false)) }
      end
    end

    context 'terminal width detection' do
      context 'when output responds to winsize' do
        let(:output) { instance_double(IO, tty?: true, winsize: [24, 120]) }

        it 'uses the terminal width from winsize' do
          expect(subject.format.terminal_width).to eql(120)
        end
      end

      context 'when not a tty' do
        let(:output) { instance_double(IO, tty?: false, winsize: [24, 120]) }

        before do
          allow(output).to receive(:respond_to?).with(:tty?).and_return(true)
        end

        it 'uses the default terminal width' do
          expect(subject.format.terminal_width).to eql(80)
        end
      end

      context 'when output does not respond to winsize' do
        let(:output) { instance_double(IO, tty?: true) }

        before do
          allow(output).to receive(:respond_to?).with(:tty?).and_return(true)
          allow(output).to receive(:respond_to?).with(:winsize).and_return(false)
        end

        it 'uses the default terminal width' do
          expect(subject.format.terminal_width).to eql(80)
        end
      end

      context 'when winsize raises Errno::ENOTTY' do
        let(:output) { instance_double(IO, tty?: true, winsize: nil) }

        before do
          allow(output).to receive(:winsize).and_raise(Errno::ENOTTY)
        end

        it 'uses the default terminal width' do
          expect(subject.format.terminal_width).to eql(80)
        end
      end

      context 'when winsize raises Errno::EOPNOTSUPP' do
        let(:output) { instance_double(IO, tty?: true, winsize: nil) }

        before do
          allow(output).to receive(:winsize).and_raise(Errno::EOPNOTSUPP)
        end

        it 'uses the default terminal width' do
          expect(subject.format.terminal_width).to eql(80)
        end
      end
    end
  end

  describe '#warn' do
    subject { object.warn(message) }

    let(:message) { 'message' }

    context 'when print warnings is disabled' do
      it_reports('')
    end

    context 'when print warnings is enabled' do
      let(:object) { super().with(print_warnings: true) }

      it_reports("message\n")
    end
  end

  describe '#delay' do
    subject { object.delay }

    it { should eql(1.0) }
  end

  describe '#start' do
    subject { object.start(env) }

    it_reports(<<~REPORT)
      Mutant environment:
      Usage:           unknown
      Matcher:         #<Mutant::Matcher::Config empty>
      Integration:     null
      Jobs:            auto
      Includes:        []
      Requires:        []
      Operators:       light
      MutationTimeout: 5
      Subjects:        1
      All-Tests:       2
      Available-Tests: 1
      Selected-Tests:  1
      Tests/Subject:   1.00 avg
      Mutations:       2
    REPORT
  end

  describe '#test_start' do
    subject { object.test_start(env) }

    it_reports(<<~REPORT)
      Test environment:
      Fail-Fast:    false
      Integration:  null
      Jobs:         auto
      Tests:        2
    REPORT
  end

  describe '#report' do
    subject { object.report(env_result) }

    context 'in non-TTY mode' do
      it_reports(<<~REPORT)
        Mutant environment:
        Usage:           unknown
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     null
        Jobs:            auto
        Includes:        []
        Requires:        []
        Operators:       light
        MutationTimeout: 5
        Subjects:        1
        All-Tests:       2
        Available-Tests: 1
        Selected-Tests:  1
        Tests/Subject:   1.00 avg
        Mutations:       2
        Results:         2
        Kills:           2
        Alive:           0
        Timeouts:        0
        Runtime:         4.00s
        Killtime:        2.00s
        Efficiency:      50.00%
        Mutations/s:     0.50
        Coverage:        100.00%
      REPORT
    end

    context 'in TTY mode' do
      let(:tty?)      { true }
      let(:output_io) { instance_double(IO, winsize: [24, 80]) }

      # rubocop:disable Layout/LineLength
      # Bar width is dynamically calculated based on terminal_width (80) minus other content
      let(:expected_progress_line) do
        Unparser::Color::GREEN.format('RUNNING 2/2 (100.0%) ██████████████████████████████████████ alive: 0 4.0s 0.50/s')
      end
      # rubocop:enable Layout/LineLength

      it 'writes final progress bar before report' do
        expect(subject).to be(object)
        expect(contents).to start_with("\r\e[2K#{expected_progress_line}\n")
      end

      it 'includes the full report after progress bar' do
        subject
        expect(contents).to include('Coverage:        100.00%')
      end
    end
  end

  describe '#progress' do
    subject { object.progress(status) }

    context 'with empty scheduler' do
      with(:env_result) { { subject_results: [] } }

      let(:tty?)      { true }
      let(:output_io) { instance_double(IO, winsize: [24, 80]) }

      # rubocop:disable Layout/LineLength
      # Bar width is dynamically calculated based on terminal_width (80) minus other content
      it_reports "\r\e[2K#{Unparser::Color::GREEN.format('RUNNING 0/2 (  0.0%) ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ alive: 0 4.0s 0.00/s')}"
      # rubocop:enable Layout/LineLength
    end

    context 'with last mutation present' do
      with(:env_result) { { subject_results: [subject_a_result] } }

      context 'when mutation is successful' do
        it_reports "progress: 02/02 alive: 0 runtime: 4.00s killtime: 2.00s mutations/s: 0.50\n"
      end

      context 'when mutation is NOT successful' do
        with(:mutation_a_criteria_result) { { test_result: false } }

        it_reports "progress: 02/02 alive: 1 runtime: 4.00s killtime: 2.00s mutations/s: 0.50\n"
      end
    end
  end

  describe '#test_progress' do
    subject { object.test_progress(test_status) }

    let(:tty?)      { true }
    let(:output_io) { instance_double(IO, winsize: [24, 80]) }

    let(:test_env) do
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
        payload:     test_env
      )
    end

    # rubocop:disable Layout/LineLength
    # Bar width is dynamically calculated based on terminal_width (80) minus other content
    it_reports "\r\e[2K#{Unparser::Color::GREEN.format('TESTING 0/2 (  0.0%) ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ failed: 0 1.0s 0.00/s')}"
    # rubocop:enable Layout/LineLength
  end

  describe '#test_report' do
    subject { object.test_report(test_env) }

    let(:test_env) do
      Mutant::Result::TestEnv.new(
        env:,
        runtime:      1.0,
        test_results: []
      )
    end

    context 'in non-TTY mode' do
      it_reports <<~'STR'
        Test environment:
        Fail-Fast:    false
        Integration:  null
        Jobs:         auto
        Tests:        2
        Test-Results: 0
        Test-Failed:  0
        Test-Success: 0
        Runtime:      1.00s
        Testtime:     0.00s
        Efficiency:   0.00%
      STR
    end

    context 'in TTY mode' do
      let(:tty?)      { true }
      let(:output_io) { instance_double(IO, winsize: [24, 80]) }

      # rubocop:disable Layout/LineLength
      let(:expected_progress_line) do
        Unparser::Color::GREEN.format('TESTING 0/2 (  0.0%) ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ failed: 0 1.0s 0.00/s')
      end
      # rubocop:enable Layout/LineLength

      it 'writes final progress bar before report' do
        expect(subject).to be(object)
        expect(contents).to start_with("\r\e[2K#{expected_progress_line}\n")
      end

      it 'includes the full report after progress bar' do
        subject
        expect(contents).to include('Efficiency:   0.00%')
      end
    end
  end
end
