RSpec.describe Mutant::Runner::Worker do
  setup_shared_context

  let(:actor)  { actor_env.actor(:worker)         }
  let(:parent) { actor_env.actor(:parent).sender  }

  before do
    message_sequence.add(:parent, :ready, actor.sender)
  end

  let(:attributes) do
    {
      config: config,
      parent: parent,
      id:     1
    }
  end

  describe '.run' do
    subject { described_class.run(attributes) }

    let(:actor_names) { [:worker] }

    context 'when receving :job command' do

      let(:test_result) { double('Test Result') }

      before do
        expect(mutation).to receive(:kill).with(config.isolation, config.integration).and_return(test_result).ordered

        message_sequence.add(:worker, :job, job)
        message_sequence.add(:parent, :result, job_result)
        message_sequence.add(:parent, :ready, actor.sender)
        message_sequence.add(:worker, :stop)
      end

      let(:test)            { double('Test')                                                   }
      let(:index)           { double('Index')                                                  }
      let(:test_result)     { double('Test Result')                                            }
      let(:mutation)        { double('Mutation')                                               }
      let(:job_result)      { Mutant::Runner::JobResult.new(job: job, result: mutation_result) }
      let(:job)             { Mutant::Runner::Job.new(index: index, mutation: mutation)        }

      let(:mutation_result) do
        Mutant::Result::Mutation.new(
          mutation:    mutation,
          index:       job.index,
          test_result: test_result
        )
      end

      it 'signals ready and status to parent' do
        subject
      end

      it { should eql(actor.sender) }

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
