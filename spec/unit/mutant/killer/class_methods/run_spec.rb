require 'spec_helper'

describe Mutant::Killer,'.new' do
  subject { class_under_test.new(strategy,mutation) }

  let(:strategy) { mock('Strategy') }

  let(:mutation)         { mock('Mutation')  }

  let(:class_under_test) do
    Class.new(described_class) do
      define_method(:run) { false }
    end
  end

  before do
    mutation.stub(:insert)
  end

  it { should be_kind_of(class_under_test) }

  it 'should insert mutation' do
    mutation.should_receive(:insert)
    subject
  end
end
