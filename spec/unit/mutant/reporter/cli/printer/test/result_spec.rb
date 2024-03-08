# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::Test::Result do
  setup_shared_context

  let(:reportable) do
    Mutant::Result::Test.new(
      output:  '<test-output>',
      passed:  false,
      runtime: 0.1
    )
  end

  it_reports <<~'STR'
    <test-output>
  STR
end
