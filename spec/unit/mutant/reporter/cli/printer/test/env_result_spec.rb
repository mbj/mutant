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
      output:  '<test-output>',
      passed:  false,
      runtime: 0.1
    )
  end

  let(:test_result_b) do
    Mutant::Result::Test.new(
      output:  '<test-output>',
      passed:  true,
      runtime: 0.2
    )
  end

  describe '.call' do
    it_reports <<~'STR'
      <test-output>
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
end
