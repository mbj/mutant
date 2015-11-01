RSpec.describe Mutant::Actor::Binding do
  let_instance(:sender_a,   Mutant::Actor::Sender                                           )
  let_instance(:sender_b,   Mutant::Actor::Sender                                           )
  let_instance(:mailbox,    Mutant::Actor::Mailbox, receiver: :receiver_a, sender: :sender_a)
  let_instance(:receiver_a, Mutant::Actor::Receiver                                         )

  let_anon(:payload)
  let_anon(:type)

  let(:object) { described_class.new(mailbox, sender_b) }

  describe '#call' do
    subject { object.call(type) }

    before do
      expect(sender_b).to receive(:call).with(message(type, sender_a)).ordered
      expect(receiver_a).to receive(:call).ordered.and_return(message(response_type, payload))
    end

    context 'when return type equals request type' do
      let(:response_type) { type }
      it { should be(payload) }
    end

    context 'when return type NOT equals request type' do
      let(:response_type) { double('Other Type') }

      it 'raises error' do
        expect { subject }.to raise_error(Mutant::Actor::ProtocolError, "Expected #{type} but got #{response_type}")
      end
    end
  end
end
