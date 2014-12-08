RSpec.describe Mutant::Runner do
  setup_shared_context

  let(:integration)    { double('Integration')      }
  let(:master_sender)  { actor_env.spawn            }
  let(:runner_actor)   { actor_env.mailbox(:runner) }

  before do
    expect(integration).to receive(:setup).ordered
    expect(Mutant::Runner::Master).to receive(:call).with(env).and_return(master_sender).ordered
  end

  describe '.call' do
    update(:config) { { integration: integration } }
    let(:actor_names) { [:runner, :master] }

    subject { described_class.call(env) }

    context 'when status done gets returned immediately' do
      before do
        message_sequence.add(:runner, :status, actor_env.mailbox(:current).sender)
        message_sequence.add(:current, :status, status)
        message_sequence.add(:runner, :stop, actor_env.mailbox(:current).sender)
        message_sequence.add(:current, :stop)
      end

      it 'returns env result' do
        should be(status.env_result)
      end

      it 'logs start' do
        expect { subject }.to change { config.reporter.start_calls }.from([]).to([env])
      end

      it 'logs process' do
        expect { subject }.to change { config.reporter.progress_calls }.from([]).to([status])
      end

      it 'logs result' do
        expect { subject }.to change { config.reporter.report_calls }.from([]).to([status.env_result])
      end

      it 'consumes all messages' do
        expect { subject }.to change(&message_sequence.method(:consumed?)).from(false).to(true)
      end
    end

    context 'when status done gets returned immediately' do
      let(:incomplete_status) { status.update(done: false) }

      before do
        expect(Kernel).to receive(:sleep).with(0.0).exactly(2).times.ordered

        current_sender = actor_env.mailbox(:current).sender

        message_sequence.add(:runner,  :status, current_sender)
        message_sequence.add(:current, :status, incomplete_status)
        message_sequence.add(:runner,  :status, current_sender)
        message_sequence.add(:current, :status, incomplete_status)
        message_sequence.add(:runner,  :status, current_sender)
        message_sequence.add(:current, :status, status)
        message_sequence.add(:runner,  :stop,   current_sender)
        message_sequence.add(:current, :stop)
      end

      it 'returns env result' do
        should be(status.env_result)
      end

      it 'logs start' do
        expect { subject }.to change { config.reporter.start_calls }.from([]).to([env])
      end

      it 'logs result' do
        expect { subject }.to change { config.reporter.report_calls }.from([]).to([status.env_result])
      end

      it 'logs process' do
        expected = [incomplete_status, incomplete_status, status]
        expect { subject }.to change { config.reporter.progress_calls }.from([]).to(expected)
      end

      it 'consumes all messages' do
        expect { subject }.to change(&message_sequence.method(:consumed?)).from(false).to(true)
      end
    end
  end
end
