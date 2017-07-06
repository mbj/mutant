RSpec.describe Mutant::Parallel::Worker do
  let(:actor_env) do
    FakeActor::Env.new(message_sequence, actor_names)
  end

  let(:message_sequence) { FakeActor::MessageSequence.new    }
  let(:processor)        { instance_double(Proc)             }
  let(:mailbox)          { actor_env.mailbox(:worker)        }
  let(:parent)           { actor_env.mailbox(:parent).sender }
  let(:payload)          { instance_double(Object)           }
  let(:result_payload)   { instance_double(Object)           }

  let(:attributes) do
    {
      processor: processor,
      parent:    parent,
      mailbox:   mailbox
    }
  end

  before do
    message_sequence.add(:parent, :ready, mailbox.sender)
  end

  describe '.run' do
    subject { described_class.run(attributes) }

    let(:actor_names) { [:worker] }

    context 'when receiving :job command' do

      before do
        expect(processor).to receive(:call).with(payload).and_return(result_payload)

        message_sequence.add(:worker, :job, job)
        message_sequence.add(:parent, :result, job_result)
        message_sequence.add(:parent, :ready, mailbox.sender)
        message_sequence.add(:worker, :stop)
      end

      let(:index)           { instance_double(0.class)                                            }
      let(:job_result)      { Mutant::Parallel::JobResult.new(job: job, payload: result_payload)  }
      let(:job)             { Mutant::Parallel::Job.new(index: index, payload: payload)           }

      it 'signals ready and status to parent' do
        subject
      end

      it { should be(described_class) }

      it 'consumes all messages' do
        expect { subject }.to change(&message_sequence.method(:consumed?)).from(false).to(true)
      end
    end

    context 'when receiving unknown command' do
      before do
        message_sequence.add(:worker, :other)
      end

      it 'raises error' do
        expect { subject }.to raise_error(Mutant::Actor::ProtocolError, 'Unknown command: :other')
      end
    end
  end
end
