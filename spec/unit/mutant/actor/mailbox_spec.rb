RSpec.describe Mutant::Actor::Mailbox do
  let(:mutex)              { double('Mutex') }
  let(:condition_variable) { double('Mutex') }

  before do
    allow(Mutex).to receive(:new).and_return(mutex)
    allow(ConditionVariable).to receive(:new).and_return(condition_variable)
  end

  describe '.new' do
    subject { described_class.new }

    let(:object) { described_class.new }
    let(:thread) { double('Thread')    }

    its(:sender) { should eql(Mutant::Actor::Sender.new(condition_variable, mutex, [])) }
    its(:receiver) { should eql(Mutant::Actor::Receiver.new(condition_variable, mutex, [])) }

  end

  describe '#bind' do
    let(:object) { described_class.new }
    let(:other)  { double('Sender')    }

    subject { object.bind(other) }

    it { should eql(Mutant::Actor::Binding.new(object, other)) }
  end
end
