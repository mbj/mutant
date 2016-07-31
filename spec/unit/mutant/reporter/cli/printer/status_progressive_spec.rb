RSpec.describe Mutant::Reporter::CLI::Printer::StatusProgressive do
  setup_shared_context

  let(:reportable) { status }

  describe '.call' do
    context 'with empty scheduler' do
      with(:env_result) { { subject_results: [] } }

      it_reports <<-REPORT
        (00/02) 100% - killtime: 0.00s runtime: 4.00s overhead: 4.00s
      REPORT
    end

    context 'with scheduler active on one subject' do
      context 'without progress' do
        with(:status) { { active_jobs: [].to_set } }

        it_reports(<<-REPORT)
          (02/02) 100% - killtime: 2.00s runtime: 4.00s overhead: 2.00s
        REPORT
      end

      context 'with progress' do
        with(:status) { { active_jobs: [job_b, job_a].to_set } }

        context 'on failure' do
          with(:mutation_a_test_result) { { passed: true } }

          it_reports(<<-REPORT)
            (01/02)  50% - killtime: 2.00s runtime: 4.00s overhead: 2.00s
          REPORT
        end

        context 'on success' do
          it_reports(<<-REPORT)
            (02/02) 100% - killtime: 2.00s runtime: 4.00s overhead: 2.00s
          REPORT
        end
      end
    end
  end
end
