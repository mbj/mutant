# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::EnvResult do
  setup_shared_context

  let(:reportable) { env_result }

  context 'with alive mutations' do
    with(:mutation_a_criteria_result) { { test_result: false } }

    describe '.call' do
      it_reports <<~'STR'
        Alive mutations require one of two actions:
        A) Keep the mutated code: Your tests specify the correct semantics,
           and the original code is redundant. Accept the mutation.
        B) Add a missing test: The original code is correct, but the tests
           do not verify the behavior the mutation removed.
        subject-a
        - test-a
        evil:subject-a:d27d2
        -----------------------
        @@ -1 +1 @@
        -true
        +false
        -----------------------
        Mutant environment:
        Usage:           unknown
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     null
        Jobs:            auto
        Includes:        []
        Requires:        []
        Operators:       light
        MutationTimeout: 5
        Subjects:        1
        All-Tests:       2
        Available-Tests: 1
        Selected-Tests:  1
        Tests/Subject:   1.00 avg
        Mutations:       2
        Results:         2
        Kills:           1
        Alive:           1
        Timeouts:        0
        Runtime:         4.00s
        Killtime:        2.00s
        Efficiency:      50.00%
        Mutations/s:     0.50
        Coverage:        50.00%
      STR
    end
  end

  context 'without alive mutations' do
    describe '.call' do
      it_reports <<~'STR'
        Mutant environment:
        Usage:           unknown
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     null
        Jobs:            auto
        Includes:        []
        Requires:        []
        Operators:       light
        MutationTimeout: 5
        Subjects:        1
        All-Tests:       2
        Available-Tests: 1
        Selected-Tests:  1
        Tests/Subject:   1.00 avg
        Mutations:       2
        Results:         2
        Kills:           2
        Alive:           0
        Timeouts:        0
        Runtime:         4.00s
        Killtime:        2.00s
        Efficiency:      50.00%
        Mutations/s:     0.50
        Coverage:        100.00%
      STR
    end
  end
end
