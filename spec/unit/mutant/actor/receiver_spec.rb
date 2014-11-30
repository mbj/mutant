RSpec.describe Mutant::Actor::Receiver do
  let(:mailbox) { double('Mailbox') }
  let(:mutex)   { double('Mutex')   }
  let(:message) { double('Message') }

  let(:object) { described_class.new(mutex, mailbox) }

  describe '#call' do
    subject { object.call }

    context 'when mailbox contains a message' do
      before do
        expect(mutex).to receive(:lock).ordered
        expect(mailbox).to receive(:empty?).and_return(false).ordered
        expect(mailbox).to receive(:shift).and_return(message).ordered
        expect(mutex).to receive(:unlock).ordered
      end

      it { should be(message) }
    end

    context 'when mailbox initially contains no message' do
      before do
        # 1rst failing try
        expect(mutex).to receive(:lock).ordered
        expect(mailbox).to receive(:empty?).and_return(true).ordered
        expect(mutex).to receive(:unlock).ordered
        expect(Thread).to receive(:stop).ordered
        # 2nd successful try
        expect(mutex).to receive(:lock).ordered
        expect(mailbox).to receive(:empty?).and_return(false).ordered
        expect(mailbox).to receive(:shift).and_return(message).ordered
        expect(mutex).to receive(:unlock).ordered
      end

      it 'waits for message' do
        should be(message)
      end
    end

    context 'when mailbox contains no message but thread gets waken without message arrived' do
      before do
        # 1rst failing try
        expect(mutex).to receive(:lock).ordered
        expect(mailbox).to receive(:empty?).and_return(true).ordered
        expect(mutex).to receive(:unlock).ordered
        expect(Thread).to receive(:stop).ordered
        # 2nd failing try
        expect(mutex).to receive(:lock).ordered
        expect(mailbox).to receive(:empty?).and_return(true).ordered
        expect(mutex).to receive(:unlock).ordered
        expect(Thread).to receive(:stop).ordered
      end

      it 'waits for message' do
        expect { subject }.to raise_error(Mutant::Actor::ProtocolError)
      end
    end
  end
end
