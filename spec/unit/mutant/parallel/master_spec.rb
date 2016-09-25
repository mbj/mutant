RSpec.describe Mutant::Parallel::Master do
  let(:message_sequence)     { FakeActor::MessageSequence.new                                             }
  let(:actor_names)          { %i[master worker_a worker_b]                                               }
  let(:sink)                 { FakeSink.new                                                               }
  let(:processor)            { instance_double(Proc)                                                      }
  let(:worker_a)             { actor_env.mailbox(:worker_a).sender                                        }
  let(:worker_b)             { actor_env.mailbox(:worker_b).sender                                        }
  let(:parent)               { actor_env.mailbox(:parent).sender                                          }
  let(:job_payload_a)        { instance_double(Object)                                                    }
  let(:job_payload_b)        { instance_double(Object)                                                    }
  let(:job_result_payload_a) { instance_double(Object)                                                    }
  let(:job_result_payload_b) { instance_double(Object)                                                    }
  let(:job_a)                { Mutant::Parallel::Job.new(index: 0, payload: job_payload_a)                }
  let(:job_b)                { Mutant::Parallel::Job.new(index: 1, payload: job_payload_b)                }
  let(:job_result_a)         { Mutant::Parallel::JobResult.new(job: job_a, payload: job_result_payload_a) }
  let(:job_result_b)         { Mutant::Parallel::JobResult.new(job: job_b, payload: job_result_payload_b) }

  let(:actor_env) do
    FakeActor::Env.new(message_sequence, actor_names)
  end

  shared_examples_for 'master behavior' do
    it { should eql(actor_env.mailbox(:master).sender) }

    it 'has expected results in sink' do
      subject
      expect(sink.results).to eql(expected_results)
    end

    it 'consumes all messages' do
      subject
      expect(message_sequence.messages).to eql([])
    end
  end

  let(:config) do
    Mutant::Parallel::Config.new(
      env:       actor_env,
      jobs:      1,
      processor: processor,
      sink:      sink,
      source:    Mutant::Parallel::Source::Array.new([job_payload_a, job_payload_b])
    )
  end

  class FakeSink
    def initialize
      @results = []
      @stop    = false
    end

    attr_reader :results

    def status
      @results.length
    end

    def result(result)
      @results << result
    end

    def stop
      @stop = true
      self
    end

    def stop?
      @stop
    end
  end # FakeSink

  # Needed because of rubies undefined-ivar-read-is-nil stuff
  describe 'object initialization' do
    let(:object) { described_class.__send__(:new, config, actor_env.mailbox(:master)) }

    it 'initializes falsy ivars' do
      expect(object.instance_variable_get(:@stop)).to be(false)
    end
  end

  describe '.call' do

    before do
      expect(Mutant::Parallel::Worker).to receive(:run).with(
        mailbox:   actor_env.mailbox(:worker_a),
        processor: processor,
        parent:    actor_env.mailbox(:master).sender
      ).and_return(worker_a)
    end

    subject { described_class.call(config) }

    context 'with multiple workers configured' do
      let(:config)           { super().with(jobs: 2) }
      let(:expected_results) { []                    }

      before do
        expect(Mutant::Parallel::Worker).to receive(:run).with(
          mailbox:   actor_env.mailbox(:worker_b),
          processor: processor,
          parent:    actor_env.mailbox(:master).sender
        ).and_return(worker_b)

        sink.stop

        message_sequence.add(:master,   :ready, worker_a)
        message_sequence.add(:worker_a, :stop)

        message_sequence.add(:master,   :ready, worker_b)
        message_sequence.add(:worker_b, :stop)

        message_sequence.add(:master,   :stop, parent)
        message_sequence.add(:parent,   :stop)
      end

      include_examples 'master behavior'
    end

    context 'explicit stop by scheduler state' do
      context 'before jobs are processed' do
        let(:expected_results) { [] }

        before do
          sink.stop

          message_sequence.add(:master,   :ready, worker_a)
          message_sequence.add(:worker_a, :stop)

          message_sequence.add(:master,   :stop, parent)
          message_sequence.add(:parent,   :stop)
        end

        include_examples 'master behavior'
      end

      context 'while jobs are processed' do
        let(:sink) do
          super().instance_eval do
            def stop?
              @results.length.equal?(1)
            end
            self
          end
        end

        before do
          message_sequence.add(:master,   :ready,  worker_a)
          message_sequence.add(:worker_a, :job,    job_a)
          message_sequence.add(:master,   :result, job_result_a)

          message_sequence.add(:master,   :ready,  worker_a)
          message_sequence.add(:worker_a, :stop)

          message_sequence.add(:master,   :stop, parent)
          message_sequence.add(:parent,   :stop)
        end

        it { should eql(actor_env.mailbox(:master).sender) }

        it 'consumes all messages' do
          expect { subject }.to change(&message_sequence.method(:consumed?)).from(false).to(true)
        end
      end
    end

    context 'external stop' do
      context 'after jobs are done' do
        let(:expected_results) { [job_result_payload_a, job_result_payload_b] }

        before do
          message_sequence.add(:master,   :ready,  worker_a)
          message_sequence.add(:worker_a, :job,    job_a)
          message_sequence.add(:master,   :result, job_result_a)

          message_sequence.add(:master,   :ready,  worker_a)
          message_sequence.add(:worker_a, :job,    job_b)
          message_sequence.add(:master,   :result, job_result_b)

          message_sequence.add(:master,   :ready,  worker_a)
          message_sequence.add(:worker_a, :stop)

          message_sequence.add(:master,   :stop, parent)
          message_sequence.add(:parent,   :stop)
        end

        include_examples 'master behavior'
      end

      context 'when no jobs are active' do
        let(:expected_results) { [job_result_payload_a] }

        before do
          message_sequence.add(:master,   :ready,  worker_a)
          message_sequence.add(:worker_a, :job,    job_a)
          message_sequence.add(:master,   :stop,   parent)
          message_sequence.add(:master,   :result, job_result_a)

          message_sequence.add(:master,   :ready,  worker_a)
          message_sequence.add(:worker_a, :stop)

          message_sequence.add(:parent,   :stop)
        end

        include_examples 'master behavior'
      end

      context 'before any job got processed' do
        let(:expected_results) { [] }

        before do
          message_sequence.add(:master,   :stop,   parent)
          message_sequence.add(:master,   :ready,  worker_a)
          message_sequence.add(:worker_a, :stop)
          message_sequence.add(:parent,   :stop)
        end

        include_examples 'master behavior'
      end
    end

    context 'requesting status' do
      context 'when jobs are done' do
        let(:expected_status)  { Mutant::Parallel::Status.new(payload: 2, active_jobs: Set.new, done: true) }
        let(:expected_results) { [job_result_payload_a, job_result_payload_b] }

        before do
          message_sequence.add(:master,   :ready,  worker_a)
          message_sequence.add(:worker_a, :job,    job_a)
          message_sequence.add(:master,   :result, job_result_a)

          message_sequence.add(:master,   :ready,  worker_a)
          message_sequence.add(:worker_a, :job,    job_b)
          message_sequence.add(:master,   :result, job_result_b)

          message_sequence.add(:master,   :ready,  worker_a)
          message_sequence.add(:worker_a, :stop)

          message_sequence.add(:master,   :status, parent)

          # Special bit to kill a mutation that results in mutable active_jobs being passed.
          message_sequence.add(:parent,   :status, expected_status) do |message|
            expect(message.payload.active_jobs.frozen?).to be(true)
          end
          message_sequence.add(:master,   :stop, parent)
          message_sequence.add(:parent,   :stop)
        end

        include_examples 'master behavior'
      end

      context 'just after scheduler stops' do
        let(:expected_status)  { Mutant::Parallel::Status.new(payload: 1, active_jobs: [].to_set, done: true) }
        let(:expected_results) { [job_result_payload_a] }

        let(:sink) do
          super().instance_eval do
            def stop?
              @results.length.equal?(1)
            end
            self
          end
        end

        before do
          message_sequence.add(:master,   :ready,  worker_a)
          message_sequence.add(:worker_a, :job,    job_a)
          message_sequence.add(:master,   :result, job_result_a)

          message_sequence.add(:master,   :status, parent)
          message_sequence.add(:parent,   :status, expected_status)

          message_sequence.add(:master,   :ready,  worker_a)
          message_sequence.add(:worker_a, :stop)

          message_sequence.add(:master,   :stop, parent)
          message_sequence.add(:parent,   :stop)
        end

        include_examples 'master behavior'
      end

      context 'when jobs are active' do
        let(:expected_status)  { Mutant::Parallel::Status.new(payload: 1, active_jobs: [job_b].to_set, done: false) }
        let(:expected_results) { [job_result_payload_a, job_result_payload_b] }

        before do
          message_sequence.add(:master,   :ready,  worker_a)
          message_sequence.add(:worker_a, :job,    job_a)
          message_sequence.add(:master,   :result, job_result_a)

          message_sequence.add(:master,   :ready,  worker_a)
          message_sequence.add(:worker_a, :job,    job_b)

          message_sequence.add(:master,   :status, parent)
          message_sequence.add(:parent,   :status, expected_status)

          message_sequence.add(:master,   :result, job_result_b)

          message_sequence.add(:master,   :ready,  worker_a)
          message_sequence.add(:worker_a, :stop)

          message_sequence.add(:master,   :stop, parent)
          message_sequence.add(:parent,   :stop)
        end

        include_examples 'master behavior'
      end

      context 'before jobs are done' do
        let(:expected_status)  { Mutant::Parallel::Status.new(payload: 0, active_jobs: Set.new, done: false) }
        let(:expected_results) { [] }

        before do
          message_sequence.add(:master,   :status, parent)
          message_sequence.add(:parent,   :status, expected_status)
          message_sequence.add(:master,   :stop,   parent)
          message_sequence.add(:master,   :ready,  worker_a)
          message_sequence.add(:worker_a, :stop)
          message_sequence.add(:parent,   :stop)
        end

        include_examples 'master behavior'
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
  end
end
