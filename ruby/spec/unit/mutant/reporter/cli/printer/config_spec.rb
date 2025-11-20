# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::Config do
  setup_shared_context

  context 'on absent jobs' do
    let(:reportable) { config.with(jobs: nil) }

    describe '.call' do
      it_reports(<<~'REPORT')
        Usage:           unknown
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     null
        Jobs:            auto
        Includes:        []
        Requires:        []
        Operators:       light
        MutationTimeout: 5
      REPORT
    end
  end

  context 'on present jobs' do
    let(:reportable) { config.with(jobs: 10) }

    describe '.call' do
      it_reports(<<~'REPORT')
        Usage:           unknown
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     null
        Jobs:            10
        Includes:        []
        Requires:        []
        Operators:       light
        MutationTimeout: 5
      REPORT
    end
  end

  context 'on absent integration' do
    let(:reportable) { config }

    describe '.call' do
      it_reports(<<~'REPORT')
        Usage:           unknown
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     null
        Jobs:            auto
        Includes:        []
        Requires:        []
        Operators:       light
        MutationTimeout: 5
      REPORT
    end
  end

  context 'on present integration' do
    let(:reportable) { config.with(integration: Mutant::Integration::Config::DEFAULT.with(name: 'foo')) }

    describe '.call' do
      it_reports(<<~'REPORT')
        Usage:           unknown
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     foo
        Jobs:            auto
        Includes:        []
        Requires:        []
        Operators:       light
        MutationTimeout: 5
      REPORT
    end
  end

  context 'on present mutaiton timeout' do
    let(:reportable) { config.with(mutation: config.mutation.with(timeout: 2.1)) }

    describe '.call' do
      it_reports(<<~'REPORT')
        Usage:           unknown
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     null
        Jobs:            auto
        Includes:        []
        Requires:        []
        Operators:       light
        MutationTimeout: 2.1
      REPORT
    end
  end
end
