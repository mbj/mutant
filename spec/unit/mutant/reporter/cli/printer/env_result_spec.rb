RSpec.describe Mutant::Reporter::CLI::Printer::EnvResult do
  setup_shared_context

  with(:mutation_a_test_result) { { passed: true } }

  let(:reportable) { env_result }

  describe '.call' do
    it_reports <<-'STR'
      subject-a
      - test-a
      evil:subject-a:d27d2
      @@ -1,2 +1,2 @@
      -true
      +false
      -----------------------
      Mutant configuration:
      Matcher:         #<Mutant::Matcher::Config empty>
      Integration:     Mutant::Integration::Null
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
    STR
  end
end
