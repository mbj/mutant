# encoding: utf-8

require 'spec_helper'

describe Mutant::Runner::Mutation, '#killer' do
  let(:object) { described_class.run(config, mutation) }

  let(:config) do
    double(
      'Config',
      fail_fast: fail_fast,
      reporter:  reporter,
      strategy:  strategy
    )
  end

  let(:reporter)  { double('Reporter')                          }
  let(:mutation)  { double('Mutation', class: Mutant::Mutation) }
  let(:strategy)  { double('Strategy')                          }
  let(:killer)    { double('Killer', success?: success)         }
  let(:fail_fast) { false                                       }
  let(:success)   { false                                       }

  subject { object.killer }

  before do
    reporter.stub(report: reporter)
    strategy.stub(kill: killer)
  end

  it 'should call configuration to identify strategy' do
    config.should_receive(:strategy).with(no_args).and_return(strategy)
    should be(killer)
  end

  it 'should run killer' do
    strategy.should_receive(:kill).with(mutation).and_return(killer)
    should be(killer)
  end

  it { should be(killer) }

  it_should_behave_like 'an idempotent method'
end
