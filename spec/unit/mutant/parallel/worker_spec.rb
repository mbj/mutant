# frozen_string_literal: true

RSpec.describe Mutant::Parallel::Worker do
  let(:active_jobs)     { instance_double(Set)                                  }
  let(:connection)      { instance_double(Mutant::Pipe::Connection)             }
  let(:index)           { 0                                                     }
  let(:payload_a)       { instance_double(Object)                               }
  let(:pid)             { instance_double(Integer)                              }
  let(:result_a)        { instance_double(Object)                               }
  let(:running)         { 1                                                     }
  let(:sink)            { instance_double(Mutant::Parallel::Sink)               }
  let(:source)          { instance_double(Mutant::Parallel::Source)             }
  let(:var_active_jobs) { instance_double(Mutant::Variable::IVar, :active_jobs) }
  let(:var_final)       { instance_double(Mutant::Variable::IVar, :final)       }
  let(:var_running)     { instance_double(Mutant::Variable::MVar, :running)     }
  let(:var_sink)        { instance_double(Mutant::Variable::IVar, :sink)        }
  let(:var_source)      { instance_double(Mutant::Variable::IVar, :source)      }
  let(:world)           { fake_world                                            }

  let(:shared) do
    {
      var_active_jobs: var_active_jobs,
      var_final:       var_final,
      var_running:     var_running,
      var_sink:        var_sink,
      var_source:      var_source
    }
  end

  describe '#call' do
    let(:job_a) do
      instance_double(
        Mutant::Parallel::Source::Job,
        payload: payload_a
      )
    end

    subject do
      described_class.new(
        connection: connection,
        index:      index,
        pid:        pid,
        process:    world.process,
        **shared
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
        receiver:  connection,
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

  describe '#join' do
    let(:object) do
      described_class.new(
        connection: connection,
        index:      index,
        pid:        pid,
        process:    world.process,
        **shared
      )
    end

    def apply
      object.join
    end

    let(:raw_expectations) do
      [
        {
          receiver:  world.process,
          selector:  :kill,
          arguments: ['TERM', pid]
        },
        {
          receiver:  world.process,
          selector:  :wait,
          arguments: [pid]
        }
      ]
    end

    it 'terminates and waits for process' do
      verify_events { expect(apply).to be(object) }
    end
  end

  describe '.start' do
    let(:block)              { ->(value) { value * 2 }                   }
    let(:child_connection)   { instance_double(Mutant::Pipe::Connection) }
    let(:parent_connection)  { instance_double(Mutant::Pipe::Connection) }
    let(:forked_main_thread) { instance_double(Thread)                   }
    let(:process_name)       { 'worker-process'                          }

    def io(name)
      instance_double(IO, name)
    end

    def pipe(name)
      instance_double(
        Mutant::Pipe,
        name,
        to_reader: io("#{name}_reader"),
        to_writer: io("#{name}_writer")
      )
    end

    let(:request_pipe)  { pipe(:request)  }
    let(:response_pipe) { pipe(:response) }

    # rubocop:disable Metrics/MethodLength
    def apply
      described_class.start(
        block:           block,
        index:           index,
        process_name:    process_name,
        var_active_jobs: var_active_jobs,
        var_final:       var_final,
        var_running:     var_running,
        var_sink:        var_sink,
        var_source:      var_source,
        world:           world
      )
    end
    # rubocop:enable Metrics/MethodLength

    let(:raw_expectations) do
      [
        {
          receiver:  Mutant::Pipe,
          selector:  :from_io,
          arguments: [world.io],
          reaction:  { return: request_pipe }
        },
        {
          receiver:  Mutant::Pipe,
          selector:  :from_io,
          arguments: [world.io],
          reaction:  { return: response_pipe }
        },
        {
          receiver: world.process,
          selector: :fork,
          reaction: { yields: [], return: pid }
        },
        {
          receiver: world.thread,
          selector: :current,
          reaction: { return: forked_main_thread }
        },
        {
          receiver:  forked_main_thread,
          selector:  :name=,
          arguments: ['worker-process']
        },
        {
          receiver:  world.process,
          selector:  :setproctitle,
          arguments: ['worker-process']
        },
        {
          receiver:  Mutant::Pipe::Connection,
          selector:  :from_pipes,
          arguments: [{ marshal: world.marshal, reader: request_pipe, writer: response_pipe }],
          reaction:  { return: child_connection }
        },
        {
          receiver: child_connection,
          selector: :receive_value,
          reaction: { return: 1 }
        },
        {
          receiver:  child_connection,
          selector:  :send_value,
          arguments: [2]
        },
        {
          receiver: child_connection,
          selector: :receive_value,
          reaction: { exception: StopIteration }
        },
        {
          receiver:  Mutant::Pipe::Connection,
          selector:  :from_pipes,
          arguments: [{ marshal: world.marshal, reader: response_pipe, writer: request_pipe }],
          reaction:  { return: parent_connection }
        }
      ]
    end

    let(:expected_worker) do
      described_class.new(
        connection: parent_connection,
        index:      index,
        pid:        pid,
        process:    world.process,
        **shared
      )
    end

    it 'starts worker (process)' do
      verify_events { expect(apply).to eql(expected_worker) }
    end
  end
end
