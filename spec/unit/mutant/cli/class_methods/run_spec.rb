require 'spec_helper'

describe Mutant::CLI, '.run' do
  subject { object.run(argv) }

  let(:object)   { described_class                                        }
  let(:argv)     { mock('ARGV')                                           }
  let(:options)  { mock('Options')                                        }
  let(:runner)   { mock('Runner', :fail? => failure)                      }
  let(:instance) { mock(described_class.name, :runner_options => options) }

  before do 
    described_class.stub(:new => instance)
    Mutant::Runner.stub(:run => runner)
  end

  context 'when runner NOT fails' do
    let(:failure) { false }

    it { should be(0) }

    it 'should run with options' do
      Mutant::Runner.should_receive(:run).with(options).and_return(runner)
      should be(0)
    end
  end

  context 'when runner fails' do
    let(:failure) { true }

    it { should be(1) }

    it 'should run with options' do
      Mutant::Runner.should_receive(:run).with(options).and_return(runner)
      should be(1)
    end
  end
end
