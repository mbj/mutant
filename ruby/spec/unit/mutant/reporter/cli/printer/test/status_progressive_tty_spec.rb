# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::Test::StatusProgressive::Tty do
  setup_shared_context

  let(:reportable)      { test_status }
  let(:test_results)    { [] }
  let(:terminal_width)  { 80 }
  let(:output)          { format_output }

  def format_output
    Mutant::Reporter::CLI::Format::Output.new(
      tty:            true,
      buffer:         StringIO.new,
      terminal_width:
    )
  end

  def self.it_reports(expected_content)
    it 'writes expected report to output' do
      described_class.call(output:, object: reportable)
      output.buffer.rewind
      expect(output.buffer.read).to eql(expected_content)
    end
  end

  let(:test_env) do
    Mutant::Result::TestEnv.new(
      env:,
      runtime:      0.8,
      test_results:
    )
  end

  let(:test_status) do
    Mutant::Parallel::Status.new(
      active_jobs: 1,
      done:        false,
      payload:     test_env
    )
  end

  describe '.call' do
    context 'with empty scheduler' do
      # rubocop:disable Layout/LineLength
      it_reports Unparser::Color::GREEN.format('TESTING 0/2 (  0.0%) ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ failed: 0 0.8s 0.00/s')
      # rubocop:enable Layout/LineLength
    end

    context 'with test results' do
      let(:test_results) do
        [
          Mutant::Result::Test.new(
            job_index: 0,
            output:    '',
            passed:    false,
            runtime:   0.5
          )
        ]
      end

      # rubocop:disable Layout/LineLength
      it_reports Unparser::Color::RED.format('TESTING 1/2 ( 50.0%) ███████████████████░░░░░░░░░░░░░░░░░░ failed: 1 0.8s 1.25/s')
      # rubocop:enable Layout/LineLength
    end

    context 'with narrow terminal' do
      let(:terminal_width) { 50 }

      it_reports Unparser::Color::GREEN.format('TESTING 0/2 (  0.0%) ░░░░░░░░░░ failed: 0 0.8s 0.00/s')
    end

    context 'with wide terminal' do
      let(:terminal_width) { 200 }

      # rubocop:disable Layout/LineLength
      it_reports Unparser::Color::GREEN.format('TESTING 0/2 (  0.0%) ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ failed: 0 0.8s 0.00/s')
      # rubocop:enable Layout/LineLength
    end
  end
end
