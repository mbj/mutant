require 'spec_helper'

describe Mutant::Runner::Mutation, '#killer' do
  let(:object) { described_class.run(config, mutation) }

  let(:config) do
    mock(
      'Config',
      :reporter => reporter,
      :strategy => strategy
    )
  end

  let(:reporter) { mock('Reporter') }
  let(:mutation) { mock('Mutation') }
  let(:strategy) { mock('Strategy') }
  let(:killer)   { mock('Killer')   }

  subject { object.killer }

  before do
    reporter.stub(:report => reporter)
    strategy.stub(:kill => killer)
  end

  it 'should call configuration to identify strategy' do
    config.should_receive(:strategy).with().and_return(strategy)
    should be(killer)
  end

  it 'should run killer' do
    strategy.should_receive(:kill).with(mutation).and_return(killer)
    should be(killer)
  end

  it { should be(killer) }

  it_should_behave_like 'an idempotent method'
end
