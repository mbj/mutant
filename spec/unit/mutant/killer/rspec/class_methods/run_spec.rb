require 'spec_helper'

describe Mutant::Killer::Rspec, '.run' do

  before do
    pending
  end

  subject { object.run(mutation) }

  let(:context)      { mock('Context')  }
  let(:mutation)     { mock('Mutation') }

  let(:object)  { described_class }

  before do
    mutation.stub(:insert)
    mutation.stub(:reset)
    RSpec::Core::Runner.stub(:run => exit_status)
  end

  context 'when run exits zero' do
    let(:exit_status) { 0 }

    its(:fail?) { should be(true)  }
    it { should be_a(described_class) }
  end

  context 'when run exits nonzero' do
    let(:exit_status) { 1 }

    its(:fail?) { should be(false)   }
    it { should be_a(described_class) }
  end
end
