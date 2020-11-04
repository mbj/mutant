# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::Config do
  setup_shared_context

  context 'on absent jobs' do
    let(:reportable) { config.with(jobs: nil) }

    describe '.call' do
      it_reports(<<~'REPORT')
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     null
        Jobs:            auto
        Includes:        []
        Requires:        []
      REPORT
    end
  end

  context 'on absent integration' do
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

  context 'on present integration' do
    let(:reportable) { config.with(integration: 'foo') }

    describe '.call' do
      it_reports(<<~'REPORT')
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     foo
        Jobs:            1
        Includes:        []
        Requires:        []
      REPORT
    end
  end
end
