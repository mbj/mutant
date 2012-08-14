require 'spec_helper'

describe Mutant::Killer::Rspec, '.run' do
  subject { object.run(context, mutant) }

  let(:context)      { mock('Context')      }
  let(:mutant)       { mock('Mutant')       }

  let(:object)  { described_class }

  before do
    context.stub(:insert => context)
    context.stub(:reset => context)
    RSpec::Core::Runner.stub(:run => exit_status)
  end

  context 'when run exits zero' do
    let(:exit_status) { 0 }

    its(:killed?) { should be(false)  }
    it { should be_a(described_class) }
  end

  context 'when run exits nonzero' do
    let(:exit_status) { 1 }

    its(:killed?) { should be(true)   }
    it { should be_a(described_class) }
  end
end
