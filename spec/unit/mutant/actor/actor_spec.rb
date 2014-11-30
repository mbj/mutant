RSpec.describe Mutant::Actor do
  let(:mutex) { double('Mutex') }
  let(:thread)  { double('Thread') }

  before do
    expect(Mutex).to receive(:new).and_return(mutex)
  end

  describe Mutant::Actor::Actor do
    let(:mailbox) { Mutant::Actor::Mailbox.new }

    let(:object) { described_class.new(thread, mailbox) }

    describe '#bind' do
      let(:other) { double('Sender') }

      subject { object.bind(other) }

      it { should eql(Mutant::Actor::Binding.new(object, other)) }
    end

    describe '#sender' do
      subject { object.sender }
      it { should eql(Mutant::Actor::Sender.new(thread, mutex, [])) }
    end

    describe '#receiver' do
      subject { object.receiver }

      it 'returns receiver' do
        should eql(Mutant::Actor::Receiver.new(mutex, []))
      end
    end
  end
end
