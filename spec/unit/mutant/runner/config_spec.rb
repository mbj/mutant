# encoding: utf-8

require 'spec_helper'

describe Mutant::Runner::Config do

  let(:config) do
    double(
      'Config',
      class:    Mutant::Config,
      subjects: [subject_a, subject_b],
      strategy: strategy,
      reporter: reporter
    )
  end

  before do
    reporter.stub(report: reporter)
    strategy.stub(:setup)
    strategy.stub(:teardown)
    Mutant::Runner.stub(:run).with(config, subject_a).and_return(runner_a)
    Mutant::Runner.stub(:run).with(config, subject_b).and_return(runner_b)
  end

  let(:reporter) { double('Reporter') }
  let(:strategy) { double('Strategy') }
  let(:subject_a) { double('Subject A') }
  let(:subject_b) { double('Subject B') }

  describe '#subjects' do
    let(:object) { described_class.run(config) }

    subject { object.subjects }

    let(:runner_a)  { double('Runner A', stop?: stop_a) }
    let(:runner_b)  { double('Runner B', stop?: stop_b) }

    context 'without early stop' do
      let(:stop_a) { false }
      let(:stop_b) { false }

      it { should eql([runner_a, runner_b]) }

      it_should_behave_like 'an idempotent method'
    end

    context 'with early stop' do
      let(:stop_a) { true  }
      let(:stop_b) { false }

      it { should eql([runner_a]) }

      it_should_behave_like 'an idempotent method'
    end
  end

  describe '#success?' do
    subject { object.success? }

    let(:object) { described_class.new(config) }

    let(:runner_a) do
      double('Runner A', stop?: stop_a, success?: success_a)
    end

    let(:runner_b) do
      double('Runner B', stop?: stop_b, success?: success_b)
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
end
