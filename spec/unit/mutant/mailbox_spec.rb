RSpec.describe Mutant::Actor::Mailbox do
  describe '.new' do
    subject { described_class.new }

    its(:frozen?) { should be(true) }
  end

  before do
    allow(Mutex).to receive(:new).and_return(mutex)
  end

  let(:mutex)  { double('Mutex')     }
  let(:object) { described_class.new }
  let(:thread) { double('Thread') }

  describe '#sender' do
    subject { object.sender(thread) }

    it { should eql(Mutant::Actor::Sender.new(thread, mutex, [])) }
  end

  describe '#receiver' do
    subject { object.receiver }

    it { should eql(Mutant::Actor::Receiver.new(mutex, [])) }
  end

  describe '#actor' do
    subject { object.actor(thread) }

    it { should eql(Mutant::Actor::Actor.new(thread, object)) }
  end
end
