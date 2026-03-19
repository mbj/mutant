# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::EnvResult do
  setup_shared_context

  let(:reportable) { env_result }

  context 'with alive mutations' do
    with(:mutation_a_criteria_result) { { test_result: false } }

    describe '.call' do
      it_reports <<~'STR'
        Uncovered mutations detected, exiting nonzero!
        Alive mutations require one of two actions:
        A) Keep the mutated code: Your tests specify the correct semantics,
           and the original code is redundant. Accept the mutation.
        B) Add a missing test: The original code is correct, but the tests
           do not verify the behavior the mutation removed.
        subject-a
        tests: 1, runtime: 2.00s, killtime: 2.00s
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

  context 'with alive mutations on tty' do
    with(:mutation_a_criteria_result) { { test_result: false } }

    before do
      allow(output).to receive(:tty?).and_return(true)
    end

    describe '.call' do
      it_reports(
        [
          [Unparser::Color::NONE,  Mutant::Reporter::CLI::Printer::AliveResults::ALIVE_EXPLANATION],
          [Unparser::Color::RED,   'subject-a'],
          [Unparser::Color::NONE,
           "\ntests: 1, runtime: 2.00s, killtime: 2.00s\nevil:subject-a:d27d2\n-----------------------\n"],
          [Unparser::Color::NONE,  "@@ -1 +1 @@\n"],
          [Unparser::Color::RED,   "-true\n"],
          [Unparser::Color::GREEN, "+false\n"],
          [Unparser::Color::NONE,  "-----------------------\nMutant environment:\n"],
          [Unparser::Color::NONE,  "Usage:           unknown\n"],
          [Unparser::Color::NONE,  "Matcher:         #<Mutant::Matcher::Config empty>\n"],
          [Unparser::Color::NONE,  "Integration:     null\n"],
          [Unparser::Color::NONE,  "Jobs:            auto\n"],
          [Unparser::Color::NONE,  "Includes:        []\n"],
          [Unparser::Color::NONE,  "Requires:        []\n"],
          [Unparser::Color::NONE,  "Operators:       light\n"],
          [Unparser::Color::NONE,  "MutationTimeout: 5\n"],
          [Unparser::Color::NONE,  "Subjects:        1\n"],
          [Unparser::Color::NONE,  "All-Tests:       2\n"],
          [Unparser::Color::NONE,  "Available-Tests: 1\n"],
          [Unparser::Color::NONE,  "Selected-Tests:  1\n"],
          [Unparser::Color::NONE,  "Tests/Subject:   1.00 avg\n"],
          [Unparser::Color::NONE,  "Mutations:       2\n"],
          [Unparser::Color::NONE,  "Results:         2\n"],
          [Unparser::Color::NONE,  "Kills:           1\n"],
          [Unparser::Color::NONE,  "Alive:           1\n"],
          [Unparser::Color::NONE,  "Timeouts:        0\n"],
          [Unparser::Color::NONE,  "Runtime:         4.00s\n"],
          [Unparser::Color::NONE,  "Killtime:        2.00s\n"],
          [Unparser::Color::NONE,  "Efficiency:      50.00%\n"],
          [Unparser::Color::NONE,  "Mutations/s:     0.50\n"],
          [Unparser::Color::RED,   'Coverage:        50.00%'],
          [Unparser::Color::NONE,  "\n"]
        ].map { |color, text| color.format(text) }.join
      )
    end
  end

  context 'with two alive evil mutations' do
    with(:mutation_a_criteria_result) { { test_result: false } }
    with(:mutation_b_criteria_result) { { test_result: false } }

    describe '.call' do
      it_reports <<~'STR'
        Uncovered mutations detected, exiting nonzero!
        Alive mutations require one of two actions:
        A) Keep the mutated code: Your tests specify the correct semantics,
           and the original code is redundant. Accept the mutation.
        B) Add a missing test: The original code is correct, but the tests
           do not verify the behavior the mutation removed.
        subject-a
        tests: 1, runtime: 2.00s, killtime: 2.00s
        evil:subject-a:d27d2
        -----------------------
        @@ -1 +1 @@
        -true
        +false
        -----------------------
        (1 more alive mutation(s), use `mutant session subject SubjectA#method-a` to see all details)
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
        Kills:           0
        Alive:           2
        Timeouts:        0
        Runtime:         4.00s
        Killtime:        2.00s
        Efficiency:      50.00%
        Mutations/s:     0.50
        Coverage:        0.00%
      STR
    end
  end

  context 'with alive mutation without diff' do
    with(:mutation_a_criteria_result) { { test_result: false } }
    with(:mutation_a_result)          { { mutation_diff: nil } }

    describe '.call' do
      it_reports <<~'STR'
        Uncovered mutations detected, exiting nonzero!
        Alive mutations require one of two actions:
        A) Keep the mutated code: Your tests specify the correct semantics,
           and the original code is redundant. Accept the mutation.
        B) Add a missing test: The original code is correct, but the tests
           do not verify the behavior the mutation removed.
        subject-a
        tests: 1, runtime: 2.00s, killtime: 2.00s
        evil:subject-a:d27d2
        -----------------------
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

  context 'with noop and evil both alive' do
    with(:mutation_a_criteria_result) { { test_result: false } }
    with(:mutation_a_result)          { { mutation_type: 'noop' } }
    with(:mutation_b_criteria_result) { { test_result: false } }

    describe '.call' do
      it_reports <<~'STR'
        Uncovered mutations detected, exiting nonzero!
        Alive mutations require one of two actions:
        A) Keep the mutated code: Your tests specify the correct semantics,
           and the original code is redundant. Accept the mutation.
        B) Add a missing test: The original code is correct, but the tests
           do not verify the behavior the mutation removed.
        subject-a
        tests: 1, runtime: 2.00s, killtime: 2.00s
        evil:subject-a:d27d2
        -----------------------
        ---- Noop failure -----
        No code was inserted. And the test did NOT PASS.
        This is typically a problem of your specs not passing unmutated.
        -----------------------
        evil:subject-a:d5a9d
        -----------------------
        @@ -1 +1 @@
        -true
        +nil
        -----------------------
        selected tests (1):
        - test-a
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
        Kills:           0
        Alive:           2
        Timeouts:        0
        Runtime:         4.00s
        Killtime:        2.00s
        Efficiency:      50.00%
        Mutations/s:     0.50
        Coverage:        0.00%
      STR
    end
  end

  context 'with noop failure only' do
    with(:mutation_a_criteria_result) { { test_result: false } }
    with(:mutation_a_result)          { { mutation_type: 'noop' } }

    describe '.call' do
      it_reports <<~'STR'
        Uncovered mutations detected, exiting nonzero!
        Alive mutations require one of two actions:
        A) Keep the mutated code: Your tests specify the correct semantics,
           and the original code is redundant. Accept the mutation.
        B) Add a missing test: The original code is correct, but the tests
           do not verify the behavior the mutation removed.
        subject-a
        tests: 1, runtime: 2.00s, killtime: 2.00s
        evil:subject-a:d27d2
        -----------------------
        ---- Noop failure -----
        No code was inserted. And the test did NOT PASS.
        This is typically a problem of your specs not passing unmutated.
        -----------------------
        selected tests (1):
        - test-a
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
