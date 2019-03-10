# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::Config do
  setup_shared_context

  let(:reportable) { config }

  describe '.call' do
    it_reports(<<~'REPORT')
      Matcher:         #<Mutant::Matcher::Config empty>
      Integration:     null
      Jobs:            1
      Includes:        []
      Requires:        []
    REPORT
  end
end
