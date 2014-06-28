require 'spec_helper'

describe Mutant::Runner::Mutation do
  let(:object) { described_class.new(config, mutation, tests) }

  let(:reporter)    { double('Reporter')                                                             }
  let(:mutation)    { double('Mutation', class: Mutant::Mutation)                                    }
  let(:integration) { double('Integration')                                                          }
  let(:killer_a)    { Mutant::Killer.new(test: test_a, mutation: mutation)                           }
  let(:killer_b)    { Mutant::Killer.new(test: test_b, mutation: mutation)                           }
  let(:runner_a)    { double('Runner A', success?: success_a, stop?: stop_a, mutation_dead?: dead_a) }
  let(:runner_b)    { double('Runner B', success?: success_b, stop?: stop_b, mutation_dead?: dead_b) }
  let(:runners)     { [runner_a, runner_b]                                                           }
  let(:killers)     { [killer_a, killer_b]                                                           }
  let(:fail_fast)   { false                                                                          }
  let(:success_a)   { true                                                                           }
  let(:success_b)   { true                                                                           }
  let(:stop_a)      { false                                                                          }
  let(:stop_b)      { false                                                                          }
  let(:dead_a)      { false                                                                          }
  let(:dead_b)      { false                                                                          }
  let(:test_a)      { double('test a')                                                               }
  let(:test_b)      { double('test b')                                                               }
  let(:tests)       { [test_a, test_b]                                                               }

  before do
    expect(Mutant::Runner).to receive(:run).with(config, killer_a).and_return(runner_a)
    expect(Mutant::Runner).to receive(:run).with(config, killer_b).and_return(runner_b)
  end

  let(:config) do
    double(
      'Config',
      fail_fast: fail_fast,
      reporter:  reporter,
      integration:  integration
    )
  end

  before do
    reporter.stub(progress: reporter)
    integration.stub(killers: killers)
  end

  describe '#stop?' do
    subject { object.stop? }

    context 'when fail fast is false' do
      it { should be(false) }
    end

    context 'when fail fast is true' do
      let(:fail_fast) { true }

      context 'when all killers are successful' do
        it { should be(false) }
      end

      context 'when one killer is NOT successful' do
        let(:success_b) { false }
        it { should be(false) }
      end

      context 'when all killer are NOT successful' do
        let(:success_b) { false }
        let(:success_a) { false }

        it { should be(true) }
      end
    end
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
