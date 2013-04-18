require 'spec_helper'

describe Mutant::CLI, '.run' do
  subject { object.run(argv) }

  let(:object)     { described_class                               }
  let(:argv)       { mock('ARGV')                                  }
  let(:attributes) { mock('Options')                               }
  let(:runner)     { mock('Runner', :success? => success)          }
  let(:config)     { mock('Config')                                }
  let(:instance)   { mock(described_class.name, :config => config) }

  before do
    described_class.stub(:new => instance)
    Mutant::Runner::Config.stub(:run => runner)
  end

  context 'when runner is successful' do
    let(:success) { true }

    it { should be(0) }

    it 'should run with attributes' do
      Mutant::Runner::Config.should_receive(:run).with(config).and_return(runner)
      should be(0)
    end
  end

  context 'when runner fails' do
    let(:success) { false }

    it { should be(1) }

    it 'should run with attributes' do
      Mutant::Runner::Config.should_receive(:run).with(config).and_return(runner)
      should be(1)
    end
  end

end
