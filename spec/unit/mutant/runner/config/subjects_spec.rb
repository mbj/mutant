# encoding: utf-8

require 'spec_helper'

describe Mutant::Runner::Config, '#subjects' do
  let(:object) { described_class.run(config) }

  subject { object.subjects }

  let(:config) do
    double(
      'Config',
      :class    => Mutant::Config,
      :subjects => [subject_a, subject_b],
      :strategy => strategy,
      :reporter => reporter
    )
  end

  let(:reporter)  { double('Reporter')                   }
  let(:strategy)  { double('Strategy')                   }
  let(:subject_a) { double('Subject A')                  }
  let(:subject_b) { double('Subject B')                  }
  let(:runner_a)  { double('Runner A', :stop? => stop_a) }
  let(:runner_b)  { double('Runner B', :stop? => stop_b) }

  before do
    strategy.stub(:setup)
    strategy.stub(:teardown)
    reporter.stub(:report => reporter)
    Mutant::Runner.stub(:run).with(config, subject_a).and_return(runner_a)
    Mutant::Runner.stub(:run).with(config, subject_b).and_return(runner_b)
  end

  context 'without earily stop' do
    let(:stop_a) { false }
    let(:stop_b) { false }

    it { should eql([runner_a, runner_b]) }

    it_should_behave_like 'an idempotent method'
  end

  context 'with earily stop' do
    let(:stop_a) { true  }
    let(:stop_b) { false }

    it { should eql([runner_a]) }

    it_should_behave_like 'an idempotent method'
  end
end
