# encoding: utf-8

require 'spec_helper'

describe Mutant::Runner::Config, '#success?' do
  subject { object.success? }

  let(:object) { described_class.new(config) }

  let(:config) do
    double(
      'Config',
      reporter: reporter,
      strategy: strategy,
      subjects: [subject_a, subject_b]
    )
  end

  let(:reporter)  { double('Reporter')  }
  let(:strategy)  { double('Strategy')  }
  let(:subject_a) { double('Subject A') }
  let(:subject_b) { double('Subject B') }

  let(:runner_a) do
    double('Runner A', stop?: stop_a, success?: success_a)
  end

  let(:runner_b) do
    double('Runner B', stop?: stop_b, success?: success_b)
  end

  before do
    reporter.stub(report: reporter)
    strategy.stub(:setup)
    strategy.stub(:teardown)
    Mutant::Runner.stub(:run).with(config, subject_a).and_return(runner_a)
    Mutant::Runner.stub(:run).with(config, subject_b).and_return(runner_b)
  end

  context 'without failed subjects' do
    let(:stop_a)    { false }
    let(:stop_b)    { false }
    let(:success_a) { true  }
    let(:success_b) { true  }

    it { should be(true) }
  end

  context 'with failing subjects' do
    let(:stop_a)    { false }
    let(:stop_b)    { false }
    let(:success_a) { false }
    let(:success_b) { true  }

    it { should be(false) }
  end
end
