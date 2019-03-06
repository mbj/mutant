# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::StatusProgressive do
  setup_shared_context

  let(:reportable) { status }

  describe '.call' do
    context 'with empty scheduler' do
      with(:env_result) { { subject_results: [] } }

      it_reports <<~REPORT
        progress: 00/02 alive: 0 runtime: 4.00s killtime: 0.00s mutations/s: 0.00
      REPORT
    end

    context 'with scheduler active on one subject' do
      context 'without progress' do
        with(:status) { { active_jobs: [].to_set } }

        it_reports(<<~REPORT)
          progress: 02/02 alive: 0 runtime: 4.00s killtime: 2.00s mutations/s: 0.50
        REPORT
      end

      context 'with progress' do
        with(:status) { { active_jobs: [job_b, job_a].to_set } }

        context 'on failure' do
          with(:mutation_a_test_result) { { passed: true } }

          it_reports(<<~REPORT)
            progress: 02/02 alive: 1 runtime: 4.00s killtime: 2.00s mutations/s: 0.50
          REPORT
        end

        context 'on success' do
          it_reports(<<~REPORT)
            progress: 02/02 alive: 0 runtime: 4.00s killtime: 2.00s mutations/s: 0.50
          REPORT
        end
      end
    end
  end
end
