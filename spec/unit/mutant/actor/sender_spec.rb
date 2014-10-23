RSpec.describe Mutant::Actor::Sender do
  let(:object)   { described_class.new(thread, mutex, mailbox) }

  let(:thread)   { double('Thread')       }
  let(:mutex)    { double('Mutex')        }
  let(:mailbox)  { double('Mailbox')      }
  let(:type)     { double('Type')         }
  let(:payload)  { double('Payload')      }
  let(:_message) { message(type, payload) }

  describe '#call' do
    subject { object.call(_message) }

    before do
      expect(mutex).to receive(:synchronize).ordered.and_yield
      expect(mailbox).to receive(:<<).with(_message)
      expect(thread).to receive(:run)
    end

    it_should_behave_like 'a command method'
  end
end
