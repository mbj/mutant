# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::Test::EnvResult do
  setup_shared_context

  let(:reportable) do
    Mutant::Result::TestEnv.new(
      env:          env,
      runtime:      0.8,
      test_results: [test_result_a, test_result_b]
    )
  end

  let(:test_result_a) do
    Mutant::Result::Test.new(
      job_index: 0,
      output:    '<test-output-a>',
      passed:    false,
      runtime:   0.1
    )
  end

  let(:test_result_b) do
    Mutant::Result::Test.new(
      job_index: 1,
      output:    '<test-output-b>',
      passed:    true,
      runtime:   0.2
    )
  end

  describe '.call' do
    context 'single test failure' do
      context 'without fail fast' do
        it_reports <<~'STR'
          <test-output-a>
          Test environment:
          Fail-Fast:    false
          Integration:  null
          Jobs:         auto
          Tests:        2
          Test-Results: 2
          Test-Failed:  1
          Test-Success: 1
          Runtime:      0.80s
          Testtime:     0.30s
          Efficiency:   37.50%
        STR
      end

      context 'with fail fast' do
        let(:config) { super().with(fail_fast: true) }

        it_reports <<~'STR'
          <test-output-a>
          Test environment:
          Fail-Fast:    true
          Integration:  null
          Jobs:         auto
          Tests:        2
          Test-Results: 2
          Test-Failed:  1
          Test-Success: 1
          Runtime:      0.80s
          Testtime:     0.30s
          Efficiency:   37.50%
        STR
      end
    end

    context 'with multiple test failures' do
      let(:test_result_b) { super().with(passed: false) }

      context 'without fail fast' do
        it_reports <<~'STR'
          <test-output-a>
          <test-output-b>
          Test environment:
          Fail-Fast:    false
          Integration:  null
          Jobs:         auto
          Tests:        2
          Test-Results: 2
          Test-Failed:  2
          Test-Success: 0
          Runtime:      0.80s
          Testtime:     0.30s
          Efficiency:   37.50%
        STR
      end

      context 'with fail fast' do
        let(:config) { super().with(fail_fast: true) }

        it_reports <<~'STR'
          <test-output-a>
          Other failed tests (report suppressed from fail fast): 1
          Test environment:
          Fail-Fast:    true
          Integration:  null
          Jobs:         auto
          Tests:        2
          Test-Results: 2
          Test-Failed:  2
          Test-Success: 0
          Runtime:      0.80s
          Testtime:     0.30s
          Efficiency:   37.50%
        STR
      end
    end
  end
end
