RSpec.describe Mutant::Reporter::CLI::Printer::Status do
  setup_shared_context

  let(:reportable) { status }

  describe '.call' do
    context 'with empty scheduler' do
      with(:env_result) { { subject_results: [] } }

      it_reports <<-REPORT
        Mutant configuration:
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     null
        Expect Coverage: 100.00%
        Jobs:            1
        Includes:        []
        Requires:        []
        Subjects:        1
        Mutations:       2
        Kills:           0
        Alive:           0
        Runtime:         4.00s
        Killtime:        0.00s
        Overhead:        Inf%
        Coverage:        100.00%
        Expected:        100.00%
        Active subjects: 0
      REPORT

      context 'on non default coverage expectation' do
        with(:config) { { expected_coverage: 0.1r } }

        it_reports <<-REPORT
          Mutant configuration:
          Matcher:         #<Mutant::Matcher::Config empty>
          Integration:     null
          Expect Coverage: 10.00%
          Jobs:            1
          Includes:        []
          Requires:        []
          Subjects:        1
          Mutations:       2
          Kills:           0
          Alive:           0
          Runtime:         4.00s
          Killtime:        0.00s
          Overhead:        Inf%
          Coverage:        100.00%
          Expected:        10.00%
          Active subjects: 0
        REPORT
      end
    end

    context 'with scheduler active on one subject' do
      context 'without progress' do
        with(:status) { { active_jobs: [].to_set } }

        it_reports(<<-REPORT)
          Mutant configuration:
          Matcher:         #<Mutant::Matcher::Config empty>
          Integration:     null
          Expect Coverage: 100.00%
          Jobs:            1
          Includes:        []
          Requires:        []
          Subjects:        1
          Mutations:       2
          Kills:           2
          Alive:           0
          Runtime:         4.00s
          Killtime:        2.00s
          Overhead:        100.00%
          Coverage:        100.00%
          Expected:        100.00%
          Active subjects: 0
        REPORT
      end

      context 'with progress' do
        with(:status) { { active_jobs: [job_b, job_a].to_set } }

        context 'on failure' do
          with(:mutation_a_test_result) { { passed: true } }

          it_reports(<<-REPORT)
            Mutant configuration:
            Matcher:         #<Mutant::Matcher::Config empty>
            Integration:     null
            Expect Coverage: 100.00%
            Jobs:            1
            Includes:        []
            Requires:        []
            Subjects:        1
            Mutations:       2
            Kills:           1
            Alive:           1
            Runtime:         4.00s
            Killtime:        2.00s
            Overhead:        100.00%
            Coverage:        50.00%
            Expected:        100.00%
            Active Jobs:
            0: evil:subject-a:d27d2
            1: evil:subject-a:d5a9d
            Active subjects: 1
            subject-a mutations: 2
            F.
            (01/02)  50% - killtime: 2.00s runtime: 2.00s overhead: 0.00s
          REPORT
        end

        context 'on success' do
          it_reports(<<-REPORT)
            Mutant configuration:
            Matcher:         #<Mutant::Matcher::Config empty>
            Integration:     null
            Expect Coverage: 100.00%
            Jobs:            1
            Includes:        []
            Requires:        []
            Subjects:        1
            Mutations:       2
            Kills:           2
            Alive:           0
            Runtime:         4.00s
            Killtime:        2.00s
            Overhead:        100.00%
            Coverage:        100.00%
            Expected:        100.00%
            Active Jobs:
            0: evil:subject-a:d27d2
            1: evil:subject-a:d5a9d
            Active subjects: 1
            subject-a mutations: 2
            ..
            (02/02) 100% - killtime: 2.00s runtime: 2.00s overhead: 0.00s
          REPORT
        end
      end
    end
  end
end
