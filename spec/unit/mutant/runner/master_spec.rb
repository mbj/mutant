RSpec.describe Mutant::Runner::Master do
  setup_shared_context

  describe 'object initialization' do
    subject { described_class.__send__(:new, env, double('actor')) }

    it 'initialized instance variables' do
      expect(subject.instance_variable_get(:@stop)).to be(false)
      expect(subject.instance_variable_get(:@stopping)).to be(false)
    end
  end

  describe '.call' do
    let(:actor_names) { [:master, :worker_a]              }
    let(:worker_a)    { actor_env.actor(:worker_a).sender }
    let(:worker_b)    { actor_env.actor(:worker_b).sender }
    let(:parent)      { actor_env.actor(:parent).sender   }

    let(:job) { double('Job') }

    before do
      expect(Time).to receive(:now).and_return(Time.at(0)).at_most(5).times
      expect(Mutant::Runner::Worker).to receive(:run).with(
        id: 0,
        config: env.config,
        parent: actor_env.actor(:master).sender
      ).and_return(worker_a)
    end

    subject { described_class.call(env) }

    context 'jobs done before external stop' do
      before do
        message_sequence.add(:master,   :ready,  worker_a)
        message_sequence.add(:worker_a, :job,    job_a)
        message_sequence.add(:master,   :result, job_a_result)

        message_sequence.add(:master,   :ready,  worker_a)
        message_sequence.add(:worker_a, :job,    job_b)
        message_sequence.add(:master,   :result, job_b_result)

        message_sequence.add(:master,   :ready,  worker_a)
        message_sequence.add(:worker_a, :stop)

        message_sequence.add(:master,   :stop,   parent)
        message_sequence.add(:parent,   :stop)
      end

      it { should eql(actor_env.actor(:master).sender) }

      it 'consumes all messages' do
        expect { subject }.to change(&message_sequence.method(:consumed?)).from(false).to(true)
      end
    end

    context 'stop by fail fast trigger first' do
      update(:config)                 { { fail_fast: true } }
      update(:mutation_b_test_result) { { passed: true }    }

      before do
        message_sequence.add(:master,   :ready,  worker_a)
        message_sequence.add(:worker_a, :job,    job_a)
        message_sequence.add(:master,   :result, job_a_result)

        message_sequence.add(:master,   :ready,  worker_a)
        message_sequence.add(:worker_a, :job,    job_b)
        message_sequence.add(:master,   :result, job_b_result)

        message_sequence.add(:master,   :ready,  worker_a)
        message_sequence.add(:worker_a, :stop)

        message_sequence.add(:master,   :stop,   parent)
        message_sequence.add(:parent,   :stop)
      end

      it { should eql(actor_env.actor(:master).sender) }

      it 'consumes all messages' do
        expect { subject }.to change(&message_sequence.method(:consumed?)).from(false).to(true)
      end
    end

    context 'stop by fail fast trigger last' do
      update(:config)                 { { fail_fast: true } }
      update(:mutation_a_test_result) { { passed: true }    }

      before do
        message_sequence.add(:master,   :ready,  worker_a)
        message_sequence.add(:worker_a, :job,    job_a)
        message_sequence.add(:master,   :result, job_a_result)

        message_sequence.add(:master,   :ready,  worker_a)
        message_sequence.add(:worker_a, :stop)

        message_sequence.add(:master,   :stop,   parent)
        message_sequence.add(:parent,   :stop)
      end

      it { should eql(actor_env.actor(:master).sender) }

      it 'consumes all messages' do
        expect { subject }.to change(&message_sequence.method(:consumed?)).from(false).to(true)
      end
    end

    context 'jobs active while external stop' do
      before do
        message_sequence.add(:master,   :ready,  worker_a)
        message_sequence.add(:worker_a, :job,    job_a)
        message_sequence.add(:master,   :stop,   parent)
        message_sequence.add(:master,   :result, job_a_result)

        message_sequence.add(:master,   :status, parent)
        message_sequence.add(:parent,   :status, empty_status.update(active_jobs: [job_a].to_set))

        message_sequence.add(:master,   :ready,  worker_a)
        message_sequence.add(:worker_a, :stop)

        message_sequence.add(:parent,   :stop)
      end

      it { should eql(actor_env.actor(:master).sender) }

      it 'consumes all messages' do
        expect { subject }.to change(&message_sequence.method(:consumed?)).from(false).to(true)
      end
    end

    context 'stop with pending jobs' do
      before do
        message_sequence.add(:master,   :stop,   parent)
        message_sequence.add(:master,   :ready,  worker_a)
        message_sequence.add(:worker_a, :stop)
        message_sequence.add(:parent,   :stop)
      end

      it { should eql(actor_env.actor(:master).sender) }

      it 'consumes all messages' do
        expect { subject }.to change(&message_sequence.method(:consumed?)).from(false).to(true)
      end
    end

    context 'unhandled message received' do
      before do
        message_sequence.add(:master, :foo, parent)
      end

      it 'raises message' do
        expect { subject }.to raise_error(Mutant::Actor::ProtocolError, 'Unexpected message: :foo')
      end
    end

    context 'request status late' do
      let(:expected_status) { status.update(env_result: env_result.update(runtime: 0.0)) }

      before do
        message_sequence.add(:master,   :ready,  worker_a)
        message_sequence.add(:worker_a, :job,    job_a)
        message_sequence.add(:master,   :result, job_a_result)

        message_sequence.add(:master,   :ready,  worker_a)
        message_sequence.add(:worker_a, :job,    job_b)
        message_sequence.add(:master,   :result, job_b_result)

        message_sequence.add(:master,   :ready,  worker_a)
        message_sequence.add(:worker_a, :stop)

        message_sequence.add(:master,   :status, parent)
        message_sequence.add(:parent,   :status, expected_status)
        message_sequence.add(:master,   :stop,   parent)
        message_sequence.add(:parent,   :stop)
      end

      it { should eql(actor_env.actor(:master).sender) }

      it 'consumes all messages' do
        expect { subject }.to change(&message_sequence.method(:consumed?)).from(false).to(true)
      end
    end

    context 'request status early' do
      before do
        message_sequence.add(:master,   :status, parent)
        message_sequence.add(:parent,   :status, empty_status)
        message_sequence.add(:master,   :stop,   parent)
        message_sequence.add(:master,   :ready,  worker_a)
        message_sequence.add(:worker_a, :stop)
        message_sequence.add(:parent,   :stop)
      end

      it { should eql(actor_env.actor(:master).sender) }

      it 'consumes all messages' do
        expect { subject }.to change(&message_sequence.method(:consumed?)).from(false).to(true)
      end
    end
  end
end
