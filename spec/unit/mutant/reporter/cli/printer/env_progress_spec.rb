RSpec.describe Mutant::Reporter::CLI::Printer::EnvProgress do
  setup_shared_context

  with(:config) { { expected_coverage: 0.1r } }

  let(:reportable) { env_result }

  describe '.call' do
    context 'without progress' do
      with(:subject_a_result) { { mutation_results: [] } }

      it_reports <<-'STR'
        Mutant configuration:
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     Mutant::Integration::Null
        Expect Coverage: 10.00%
        Jobs:            1
        Includes:        []
        Requires:        []
        Subjects:        1
        Mutations:       2
        Results:         0
        Kills:           0
        Alive:           0
        Runtime:         4.00s
        Killtime:        0.00s
        Overhead:        Inf%
        Mutations/s:     0.00
        Coverage:        100.00%
        Expected:        10.00%
      STR
    end

    context 'on full coverage' do
      it_reports <<-'STR'
        Mutant configuration:
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     Mutant::Integration::Null
        Expect Coverage: 10.00%
        Jobs:            1
        Includes:        []
        Requires:        []
        Subjects:        1
        Mutations:       2
        Results:         2
        Kills:           2
        Alive:           0
        Runtime:         4.00s
        Killtime:        2.00s
        Overhead:        100.00%
        Mutations/s:     0.50
        Coverage:        100.00%
        Expected:        10.00%
      STR
    end

    context 'on partial coverage' do
      with(:mutation_a_test_result) { { passed: true } }

      it_reports <<-'STR'
        Mutant configuration:
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     Mutant::Integration::Null
        Expect Coverage: 10.00%
        Jobs:            1
        Includes:        []
        Requires:        []
        Subjects:        1
        Mutations:       2
        Results:         2
        Kills:           1
        Alive:           1
        Runtime:         4.00s
        Killtime:        2.00s
        Overhead:        100.00%
        Mutations/s:     0.50
        Coverage:        50.00%
        Expected:        10.00%
      STR
    end
  end
end
