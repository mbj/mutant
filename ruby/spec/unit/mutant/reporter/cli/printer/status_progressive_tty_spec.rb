# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::StatusProgressive::Tty do
  setup_shared_context

  let(:reportable)      { status }
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

  describe '.call' do
    context 'with empty scheduler' do
      with(:env_result) { { subject_results: [] } }

      # rubocop:disable Layout/LineLength
      it_reports Unparser::Color::GREEN.format('RUNNING 0/2 (  0.0%) ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ alive: 0 4.0s 0.00/s')
      # rubocop:enable Layout/LineLength
    end

    context 'with scheduler active on one subject' do
      with(:status) { { active_jobs: [job_b, job_a].to_set } }

      context 'on failure' do
        with(:mutation_a_criteria_result) { { test_result: false } }

        # rubocop:disable Layout/LineLength
        it_reports Unparser::Color::RED.format('RUNNING 2/2 (100.0%) ██████████████████████████████████████ alive: 1 4.0s 0.50/s')
        # rubocop:enable Layout/LineLength
      end

      context 'on success' do
        # rubocop:disable Layout/LineLength
        it_reports Unparser::Color::GREEN.format('RUNNING 2/2 (100.0%) ██████████████████████████████████████ alive: 0 4.0s 0.50/s')
        # rubocop:enable Layout/LineLength
      end
    end

    context 'with narrow terminal' do
      let(:terminal_width) { 50 }

      with(:env_result) { { subject_results: [] } }

      # Bar shrinks to fit available space
      it_reports Unparser::Color::GREEN.format('RUNNING 0/2 (  0.0%) ░░░░░░░░ alive: 0 4.0s 0.00/s')
    end

    context 'with very narrow terminal' do
      # Terminal so narrow that bar width would be negative, clamped to 0
      let(:terminal_width) { 40 }

      with(:env_result) { { subject_results: [] } }

      # Bar width is 0 (clamped from negative available_width)
      it_reports Unparser::Color::GREEN.format('RUNNING 0/2 (  0.0%)  alive: 0 4.0s 0.00/s')
    end

    context 'with wide terminal' do
      let(:terminal_width) { 200 }

      with(:env_result) { { subject_results: [] } }

      # rubocop:disable Layout/LineLength
      it_reports Unparser::Color::GREEN.format('RUNNING 0/2 (  0.0%) ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ alive: 0 4.0s 0.00/s')
      # rubocop:enable Layout/LineLength
    end
  end
end
