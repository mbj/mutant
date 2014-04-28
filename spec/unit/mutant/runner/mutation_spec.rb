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
  let(:success_a) { false                                                  }
  let(:success_b) { false                                                  }
  let(:stop_a)    { false                                                  }
  let(:stop_b)    { false                                                  }

  before do
    allow(Mutant::Runner).to receive(:run).with(config, killer_a).and_return(runner_a)
    allow(Mutant::Runner).to receive(:run).with(config, killer_b).and_return(runner_b)
  end

  describe '#killers' do
    subject { object.killers }

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

    it { should eql(runners) }

    it_should_behave_like 'an idempotent method'
  end
end
