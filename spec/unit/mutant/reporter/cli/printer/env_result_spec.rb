# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::EnvResult do
  setup_shared_context

  with(:mutation_a_test_result) { { passed: true } }

  let(:reportable) { env_result }

  describe '.call' do
    it_reports <<~'STR'
      subject-a
      - test-a
      evil:subject-a:d27d2
      -----------------------
      @@ -1 +1 @@
      -true
      +false
      -----------------------
      Mutant environment:
      Matcher:         #<Mutant::Matcher::Config empty>
      Integration:     null
      Jobs:            1
      Includes:        []
      Requires:        []
      Subjects:        1
      Total-Tests:     1
      Selected-Tests:  1
      Tests/Subject:   1.00 avg
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
