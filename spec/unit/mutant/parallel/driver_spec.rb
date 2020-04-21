# frozen_string_literal: true

RSpec.describe Mutant::Parallel::Driver do
  let(:active_jobs) { []                                    }
  let(:thread_a)    { instance_double(Thread, alive?: true) }
  let(:thread_b)    { instance_double(Thread, alive?: true) }
  let(:threads)     { [thread_a, thread_b]                  }
  let(:timeout)     { instance_double(Float)                }
  let(:sink_status) { instance_double(Object)               }

  let(:sink) do
    instance_double(
      Mutant::Parallel::Sink,
      status: sink_status
    )
  end

  let(:var_active_jobs) do
    instance_double(Variable::IVar, 'active jobs')
  end

  let(:var_final) do
    instance_double(Variable::IVar, 'final')
  end

  let(:var_sink) do
    instance_double(Variable::IVar, 'sink')
  end

  subject do
    described_class.new(
      threads:         threads,
      var_active_jobs: var_active_jobs,
      var_final:       var_final,
      var_sink:        var_sink
    )
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

    let(:raw_expectations) do
      [
        {
          receiver:  var_final,
          selector:  :take_timeout,
          arguments: [timeout],
          reaction:  { return: Variable.const_get(:Result)::Timeout.new }
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

    context 'when done' do
      before do
        allow(thread_a).to receive_messages(alive?: false)
        allow(thread_b).to receive_messages(alive?: false)
      end

      let(:raw_expectations) do
        [
          *super(),
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
end
