RSpec.describe Mutant::Reporter::CLI::Printer::StatusProgressive do
  setup_shared_context

  let(:reportable) { status }

  describe '.call' do
    context 'with empty scheduler' do
      update(:env_result) { { subject_results: [] } }

      it_reports <<-REPORT
        (00/02)   0% - killtime: 0.00s runtime: 4.00s overhead: 4.00s
      REPORT

      context 'on non default coverage expectation' do
        update(:config) { { expected_coverage: 0.1r } }

        it_reports <<-REPORT
          (00/02)   0% - killtime: 0.00s runtime: 4.00s overhead: 4.00s
        REPORT
      end
    end

    context 'with scheduler active on one subject' do
      context 'without progress' do
        update(:status) { { active_jobs: [].to_set } }

        it_reports(<<-REPORT)
          (02/02) 100% - killtime: 2.00s runtime: 4.00s overhead: 2.00s
        REPORT
      end

      context 'with progress' do
        update(:status) { { active_jobs: [job_b, job_a].to_set } }

        context 'on failure' do
          update(:mutation_a_test_result) { { passed: true } }

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
