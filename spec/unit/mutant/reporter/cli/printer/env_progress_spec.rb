# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::EnvProgress do
  setup_shared_context

  let(:reportable) { env_result }

  describe '.call' do
    context 'without progress' do
      with(:subject_a_result) { { coverage_results: [] } }

      it_reports <<~'STR'
        Mutant environment:
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     null
        Jobs:            auto
        Includes:        []
        Requires:        []
        Subjects:        1
        All-Tests:       2
        Available-Tests: 1
        Selected-Tests:  1
        Tests/Subject:   1.00 avg
        Mutations:       2
        Results:         0
        Kills:           0
        Alive:           0
        Timeouts:        0
        Runtime:         4.00s
        Killtime:        0.00s
        Overhead:        Inf%
        Mutations/s:     0.00
        Coverage:        100.00%
      STR
    end

    context 'on full coverage' do
      it_reports <<~'STR'
        Mutant environment:
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     null
        Jobs:            auto
        Includes:        []
        Requires:        []
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
        Overhead:        100.00%
        Mutations/s:     0.50
        Coverage:        100.00%
      STR
    end

    context 'on partial coverage' do
      with(:mutation_a_criteria_result) { { test_result: false } }

      it_reports <<~'STR'
        Mutant environment:
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     null
        Jobs:            auto
        Includes:        []
        Requires:        []
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
        Overhead:        100.00%
        Mutations/s:     0.50
        Coverage:        50.00%
      STR
    end
  end
end
