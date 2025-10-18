# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::Test::Config do
  setup_shared_context

  context 'on absent jobs' do
    let(:reportable) { config.with(jobs: nil) }

    describe '.call' do
      it_reports(<<~'REPORT')
        Fail-Fast:    false
        Integration:  null
        Jobs:         auto
      REPORT
    end
  end

  context 'on present jobs' do
    let(:reportable) { config.with(jobs: 10) }

    describe '.call' do
      it_reports(<<~'REPORT')
        Fail-Fast:    false
        Integration:  null
        Jobs:         10
      REPORT
    end
  end

  context 'on absent integration' do
    let(:reportable) { config }

    describe '.call' do
      it_reports(<<~'REPORT')
        Fail-Fast:    false
        Integration:  null
        Jobs:         auto
      REPORT
    end
  end

  context 'on present integration' do
    let(:reportable) { config.with(integration: Mutant::Integration::Config::DEFAULT.with(name: 'foo')) }

    describe '.call' do
      it_reports(<<~'REPORT')
        Fail-Fast:    false
        Integration:  foo
        Jobs:         auto
      REPORT
    end
  end
end
