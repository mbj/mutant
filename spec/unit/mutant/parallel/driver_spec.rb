# frozen_string_literal: true

RSpec.describe Mutant::Parallel::Driver, mutant_expression: 'Mutant::Parallel::Driver*' do
  let(:active_jobs)     { []                                                    }
  let(:sink_status)     { instance_double(Object)                               }
  let(:thread_a)        { instance_double(Thread, alive?: true)                 }
  let(:thread_b)        { instance_double(Thread, alive?: true)                 }
  let(:threads)         { [thread_a, thread_b]                                  }
  let(:timeout)         { instance_double(Float)                                }
  let(:var_active_jobs) { instance_double(Mutant::Variable::IVar, :active_jobs) }
  let(:var_final)       { instance_double(Mutant::Variable::IVar, :final)       }
  let(:var_running)     { instance_double(Mutant::Variable::MVar, :running)     }
  let(:var_sink)        { instance_double(Mutant::Variable::IVar, :sink)        }
  let(:var_source)      { instance_double(Mutant::Variable::IVar, :source)      }
  let(:workers)         { [worker_a, worker_b]                                  }
  let(:worker_a)        { instance_double(Mutant::Parallel::Worker, :a)         }
  let(:worker_b)        { instance_double(Mutant::Parallel::Worker, :b)         }

  let(:sink) do
    instance_double(
      Mutant::Parallel::Sink,
      status: sink_status
    )
  end

  subject do
    described_class.new(
      threads:         threads,
      var_active_jobs: var_active_jobs,
      var_final:       var_final,
      var_running:     var_running,
      var_sink:        var_sink,
      var_source:      var_source,
      workers:         workers
    )
  end

  describe '#stop' do
    def apply
      subject.stop
    end

    let(:raw_expectations) do
      [
        {
          receiver: thread_a,
          selector: :kill
        },
        {
          receiver: thread_b,
          selector: :kill
        }
      ]
    end

    it 'returns self' do
      verify_events do
        expect(apply).to eql(subject)
      end
    end
  end

  describe '#wait_timeout' do
    def apply
      subject.wait_timeout(timeout)
    end

    shared_examples 'returns expected status' do
      it 'returns expected status' do
        verify_events do
          expect(apply).to eql(expected_status)
        end
      end

      it 'returns frozen copy of active jobs' do
        verify_events do
          returned_active_jobs = apply.active_jobs

          expect(returned_active_jobs).to_not be(active_jobs)
          expect(returned_active_jobs.frozen?).to be(true)
        end
      end
    end

    shared_examples 'when done' do
      context 'when done' do
        before do
          allow(thread_a).to receive_messages(alive?: false)
          allow(thread_b).to receive_messages(alive?: false)
        end

        let(:raw_expectations) do
          [
            *super(),
            {
              receiver: worker_a,
              selector: :join
            },
            {
              receiver: worker_b,
              selector: :join
            },
            {
              receiver: thread_a,
              selector: :join
            },
            {
              receiver: thread_b,
              selector: :join
            }
          ]

        end

        let(:expected_status) do
          Mutant::Parallel::Status.new(
            active_jobs: active_jobs,
            done:        true,
            payload:     sink_status
          )
        end

        include_examples 'returns expected status'
      end
    end

    context 'when stopped' do
      def apply
        subject.stop
        super()
      end

      let(:raw_expectations) do
        [
          {
            receiver: thread_a,
            selector: :kill
          },
          {
            receiver: thread_b,
            selector: :kill
          },
          {
            receiver: var_active_jobs,
            selector: :with,
            reaction: { yields: [active_jobs] }
          },
          {
            receiver: var_sink,
            selector: :with,
            reaction: { yields: [sink] }
          }
        ]
      end

      include_examples 'when done'
    end

    context 'when not stopped' do
      let(:raw_expectations) do
        [
          {
            receiver:  var_final,
            selector:  :take_timeout,
            arguments: [timeout],
            reaction:  { return: Mutant::Variable.const_get(:Result)::Timeout.new }
          },
          {
            receiver: var_active_jobs,
            selector: :with,
            reaction: { yields: [active_jobs] }
          },
          {
            receiver: var_sink,
            selector: :with,
            reaction: { yields: [sink] }
          }
        ]
      end

      context 'when not done' do
        let(:expected_status) do
          Mutant::Parallel::Status.new(
            active_jobs: active_jobs,
            done:        false,
            payload:     sink_status
          )
        end

        include_examples 'returns expected status'
      end

      include_examples 'when done'
    end
  end
end
