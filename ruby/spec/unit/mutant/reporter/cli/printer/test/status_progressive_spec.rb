# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::Test::StatusProgressive do
  setup_shared_context

  let(:reportable) { test_status }
  let(:test_results) { [] }

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
      it_reports <<~REPORT
        progress: 00/02 failed: 0 runtime: 0.80s testtime: 0.00s tests/s: 0.00
      REPORT
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

      it_reports <<~REPORT
        progress: 01/02 failed: 1 runtime: 0.80s testtime: 0.50s tests/s: 1.25
      REPORT
    end
  end
end
