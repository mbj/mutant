require 'spec_helper'

describe Mutant::CLI, '.run' do
  subject { object.run(argv) }

  let(:object)   { described_class                                        }
  let(:argv)     { mock('ARGV')                                           }
  let(:options)  { mock('Options')                                        }
  let(:runner)   { mock('Runner')                                         }
  let(:instance) { mock(described_class.name, :runner_options => options) }

  before do 
    described_class.stub(:new => instance)
    Mutant::Runner.stub(:run => runner)
  end

  it { should be(runner) }

  it 'should run with options' do
    Mutant::Runner.should_receive(:run).with(options).and_return(runner)
    should be(runner)
  end
end
