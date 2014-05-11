# encoding: utf-8

require 'spec_helper'

describe Mutant::Runner::Mutation do
  let(:object) { described_class.new(config, mutation) }

  let(:reporter)  { double('Reporter')                                     }
  let(:mutation)  { double('Mutation', class: Mutant::Mutation)            }
  let(:strategy)  { double('Strategy')                                     }
  let(:killer_a)  { double('Killer A')                                     }
  let(:killer_b)  { double('Killer B')                                     }
  let(:runner_a)  { double('Runner A', success?: success_a, stop?: stop_a) }
  let(:runner_b)  { double('Runner B', success?: success_b, stop?: stop_b) }
  let(:runners)   { [runner_a, runner_b]                                   }
  let(:killers)   { [killer_a, killer_b]                                   }
  let(:fail_fast) { false                                                  }
  let(:success_a) { true                                                   }
  let(:success_b) { true                                                   }
  let(:stop_a)    { false                                                  }
  let(:stop_b)    { false                                                  }

  before do
    expect(Mutant::Runner).to receive(:run).with(config, killer_a).and_return(runner_a)
    expect(Mutant::Runner).to receive(:run).with(config, killer_b).and_return(runner_b)
  end

  let(:config) do
    double(
      'Config',
      fail_fast: fail_fast,
      reporter:  reporter,
      strategy:  strategy
    )
  end

  before do
    reporter.stub(report: reporter)
    strategy.stub(killers: killers)
  end

  describe '#success?' do
    subject { object.success? }

    context 'when all killers are successful' do
      it { should be(true) }
    end

    context 'when one killer is not successful' do
      let(:success_b) { false }

      it { should be(true) }
    end

    context 'when all killer are not successful' do
      let(:success_a) { false }
      let(:success_b) { false }

      it { should be(false) }
    end
  end

  describe '#killers' do
    subject { object.killers }


    it { should eql(runners) }

    it_should_behave_like 'an idempotent method'
  end
end
