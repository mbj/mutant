# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::EnvProgress do
  setup_shared_context

  let(:reportable) { env_result }

  describe '.call' do
    context 'without progress' do
      with(:subject_a_result) { { coverage_results: [] } }

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
        Results:         0
        Kills:           0
        Alive:           0
        Timeouts:        0
        Runtime:         4.00s
        Killtime:        0.00s
        Efficiency:      0.00%
        Mutations/s:     0.00
        Coverage:        100.00%
      STR
    end

    context 'on full coverage' do
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

    context 'on partial coverage' do
      with(:mutation_a_criteria_result) { { test_result: false } }

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

  describe '#coverage_percent' do
    let(:mock_env_result) do
      instance_double(
        Mutant::Result::Env,
        coverage: test_coverage
      )
    end

    subject(:printer) do
      described_class.__send__(:new, output: StringIO.new, object: mock_env_result)
    end

    context 'when coverage is exactly 100%' do
      let(:test_coverage) { Rational(1) }

      it 'returns exactly 100.0' do
        expect(printer.__send__(:coverage_percent)).to eq(100.0)
      end
    end

    context 'when coverage would round up to 100%' do
      # 99999/100000 = 99.999% which would round to 100.00% with normal rounding
      let(:test_coverage) { Rational(99_999, 100_000) }

      it 'floors to 99.99 instead of rounding to 100.0' do
        result = printer.__send__(:coverage_percent)
        expect(result).to eq(99.99)
        expect(result).to be < 100.0
      end
    end

    context 'when coverage is close but would not round to 100%' do
      # 99/100 = 99.0% - should display as 99.0
      let(:test_coverage) { Rational(99, 100) }

      it 'returns the floored percentage' do
        expect(printer.__send__(:coverage_percent)).to eq(99.0)
      end
    end

    context 'when coverage is 0%' do
      let(:test_coverage) { Rational(0) }

      it 'returns 0.0' do
        expect(printer.__send__(:coverage_percent)).to eq(0.0)
      end
    end

    context 'when coverage is 50%' do
      let(:test_coverage) { Rational(1, 2) }

      it 'returns 50.0' do
        expect(printer.__send__(:coverage_percent)).to eq(50.0)
      end
    end
  end
end
