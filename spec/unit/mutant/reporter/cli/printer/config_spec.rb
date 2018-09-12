# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::Config do
  setup_shared_context

  let(:reportable) { config }

  describe '.call' do
    context 'on default config' do
      it_reports(<<~REPORT)
        Mutant configuration:
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     Mutant::Integration::Null
        Jobs:            1
        Includes:        []
        Requires:        []
      REPORT
    end

    context 'with non default coverage expectation' do
      it_reports(<<~REPORT)
        Mutant configuration:
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     Mutant::Integration::Null
        Jobs:            1
        Includes:        []
        Requires:        []
      REPORT
    end
  end
end
