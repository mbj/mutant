# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::TestResult do
  setup_shared_context

  let(:reportable) { mutation_a_test_result }

  describe '.call' do
    it_reports <<~'STR'
      - 1 @ runtime: 1.0
        - test-a
      Test Output:
      mutation a test result output
    STR
  end
end
