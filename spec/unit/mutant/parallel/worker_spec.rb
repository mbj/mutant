# frozen_string_literal: true

RSpec.describe Mutant::Parallel::Worker do
  describe '#call' do
    let(:active_jobs)  { instance_double(Set)                      }
    let(:payload_a)    { instance_double(Object)                   }
    let(:payload_b)    { instance_double(Object)                   }
    let(:processor)    { instance_double(Proc)                     }
    let(:result_a)     { instance_double(Object)                   }
    let(:result_b)     { instance_double(Object)                   }
    let(:running)      { 1                                         }
    let(:sink)         { instance_double(Mutant::Parallel::Sink)   }
    let(:source)       { instance_double(Mutant::Parallel::Source) }
    let(:thread_a)     { instance_double(Thread, alive?: true)     }
    let(:thread_b)     { instance_double(Thread, alive?: true)     }
    let(:threads)      { [thread_a, thread_b]                      }
    let(:timeout)      { instance_double(Float)                    }

    let(:job_a) do
      instance_double(
        Mutant::Parallel::Source::Job,
        payload: payload_a
      )
    end

    let(:job_b) do
      instance_double(
        Mutant::Parallel::Source::Job,
        payload: payload_b
      )
    end

    let(:var_active_jobs) do
      instance_double(Variable::IVar, 'active jobs')
    end

    let(:var_final) do
      instance_double(Variable::IVar, 'final')
    end

    let(:var_running) do
      instance_double(Variable::MVar, 'running')
    end

    let(:var_sink) do
      instance_double(Variable::IVar, 'sink')
    end

    let(:var_source) do
      instance_double(Variable::IVar, 'source')
    end

    subject do
      described_class.new(
        processor:       processor,
        var_active_jobs: var_active_jobs,
        var_final:       var_final,
        var_running:     var_running,
        var_sink:        var_sink,
        var_source:      var_source
      )
    end

    def apply
      subject.call
    end

    def sink_result(result)
      {
        receiver:  sink,
        selector:  :result,
        arguments: [result]
      }
    end

    def sink_stop?(value)
      {
        receiver: sink,
        selector: :stop?,
        reaction: { return: value }
      }
    end

    def source_next?(value)
      {
        receiver: source,
        selector: :next?,
        reaction: { return: value }
      }
    end

    def source_next(value)
      {
        receiver: source,
        selector: :next,
        reaction: { return: value }
      }
    end

    def with(var, value)
      {
        receiver: var,
        selector: :with,
        reaction: { yields: [value] }
      }
    end

    def process(payload, result)
      {
        receiver:  processor,
        selector:  :call,
        arguments: [payload],
        reaction:  { return: result }
      }
    end

    def add_job(job)
      {
        receiver:  active_jobs,
        selector:  :<<,
        arguments: [job]
      }
    end

    def remove_job(job)
      {
        receiver:  active_jobs,
        selector:  :delete,
        arguments: [job]
      }
    end

    shared_examples 'worker execution' do
      it 'terminates after processing all jobs' do
        verify_events { expect(apply).to be(subject) }
      end
    end

    def modify_running
      {
        receiver: var_running,
        selector: :modify,
        reaction: { yields: [running] }
      }
    end

    def finalize
      [
        modify_running,
        {
          receiver:  var_final,
          selector:  :put,
          arguments: [nil]
        }
      ]
    end

    context 'when processing jobs till sink stops accepting' do
      let(:raw_expectations) do
        [
          with(var_source, source),
          source_next?(true),
          source_next(job_a),
          with(var_active_jobs, active_jobs),
          add_job(job_a),
          process(payload_a, result_a),
          with(var_active_jobs, active_jobs),
          remove_job(job_a),
          with(var_sink, sink),
          sink_result(result_a),
          sink_stop?(true),
          *finalize
        ]
      end

      include_examples 'worker execution'
    end

    context 'when processing jobs till source is empty' do
      let(:raw_expectations) do
        [
          with(var_source, source),
          source_next?(false),
          *finalize
        ]
      end

      include_examples 'worker execution'
    end

    context 'when worker exits as others are still going' do
      let(:running) { 2 }

      let(:raw_expectations) do
        [
          with(var_source, source),
          source_next?(false),
          modify_running
          # no finalize
        ]
      end

      include_examples 'worker execution'
    end
  end
end
