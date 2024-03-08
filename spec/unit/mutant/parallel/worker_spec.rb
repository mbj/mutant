# frozen_string_literal: true

RSpec.describe Mutant::Parallel::Worker do
  def io(name)
    instance_double(IO, name)
  end

  def pipe(name)
    reader, writer = io("#{name}_reader"), io("#{name}_writer")

    instance_double(
      Mutant::Parallel::Pipe,
      name,
      to_reader: reader,
      to_writer: writer
    )
  end

  let(:active_jobs)       { instance_double(Set)                                  }
  let(:block)             { ->(value) { value * 2 }                               }
  let(:deadline)          { instance_double(Mutant::Timer::Deadline)              }
  let(:index)             { 0                                                     }
  let(:log_pipe)          { pipe(:log)                                            }
  let(:on_process_start)  { instance_double(Proc)                                 }
  let(:payload_a)         { instance_double(Object)                               }
  let(:payload_b)         { instance_double(Object)                               }
  let(:pid)               { instance_double(Integer)                              }
  let(:process_name)      { 'worker-process'                                      }
  let(:request_pipe)      { pipe(:request)                                        }
  let(:response_pipe)     { pipe(:response)                                       }
  let(:result_a)          { instance_double(Object)                               }
  let(:result_b)          { instance_double(Object)                               }
  let(:running)           { 1                                                     }
  let(:sink)              { instance_double(Mutant::Parallel::Sink)               }
  let(:source)            { instance_double(Mutant::Parallel::Source)             }
  let(:var_active_jobs)   { instance_double(Mutant::Variable::IVar, :active_jobs) }
  let(:var_final)         { instance_double(Mutant::Variable::IVar, :final)       }
  let(:var_running)       { instance_double(Mutant::Variable::MVar, :running)     }
  let(:var_sink)          { instance_double(Mutant::Variable::IVar, :sink)        }
  let(:var_source)        { instance_double(Mutant::Variable::IVar, :source)      }

  let(:parent_connection) do
    double(
      Mutant::Parallel::Connection,
      reader: instance_double(Mutant::Parallel::Connection::Frame, io: response_pipe.to_reader)
    )
  end

  let(:world) do
    instance_double(
      Mutant::World,
      io:      class_double(IO),
      marshal: class_double(Marshal),
      process: class_double(Process),
      stderr:  instance_double(IO),
      stdout:  instance_double(IO),
      thread:  class_double(Thread)
    )
  end

  let(:shared) do
    {
      var_active_jobs: var_active_jobs,
      var_final:       var_final,
      var_running:     var_running,
      var_sink:        var_sink,
      var_source:      var_source
    }
  end

  subject do
    described_class.new(
      connection:      parent_connection,
      log_reader:      log_pipe.to_reader,
      response_reader: response_pipe.to_reader,
      pid:             pid,
      config:          described_class::Config.new(
        block:            block,
        index:            index,
        on_process_start: on_process_start,
        process_name:     process_name,
        timeout:          1.0,
        world:            world,
        **shared
      )
    )
  end

  describe '#index' do
    it 'returns index' do
      expect(subject.index).to be(index)
    end
  end

  describe '#call' do
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

    def apply
      subject.call
    end

    def sink_response(response)
      {
        receiver:  sink,
        selector:  :response,
        arguments: [response]
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

    def send_value(payload)
      {
        receiver:  parent_connection,
        selector:  :send_value,
        arguments: [payload]
      }
    end

    def receive_value(result)
      {
        receiver: connection,
        selector: :receive_value,
        reaction: { return: result }
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

    # rubocop:disable Metrics/MethodLength
    def read_response(job, response)
      {
        receiver:  Mutant::Parallel::Connection::Reader,
        arguments: [
          {
            deadline:        deadline,
            io:              world.io,
            job:             job,
            log_reader:      log_pipe.to_reader,
            marshal:         world.marshal,
            response_reader: response_pipe.to_reader
          }
        ],
        selector:  :read_response,
        reaction:  { return: response }
      }
    end
    # rubocop:enable Metrics/MethodLength

    def new_deadline
      {
        receiver:  world,
        selector:  :deadline,
        arguments: [1.0],
        reaction:  { return: deadline }
      }
    end

    let(:response_a) do
      Mutant::Parallel::Response.new(
        error:  nil,
        job:    0,
        log:    'log-a',
        result: result_a
      )
    end

    let(:response_b) do
      Mutant::Parallel::Response.new(
        error:  nil,
        job:    0,
        log:    'log-b',
        result: result_b
      )
    end

    context 'when processing single job till sink stops accepting' do
      let(:raw_expectations) do
        [
          with(var_source, source),
          source_next?(true),
          source_next(job_a),
          with(var_active_jobs, active_jobs),
          add_job(job_a),
          send_value(payload_a),
          new_deadline,
          read_response(job_a, response_a),
          with(var_active_jobs, active_jobs),
          remove_job(job_a),
          with(var_sink, sink),
          sink_response(response_a),
          sink_stop?(true),
          *finalize
        ]
      end

      include_examples 'worker execution'
    end

    context 'when processing multiple jobs till sink stops accepting' do
      let(:raw_expectations) do
        [
          with(var_source, source),
          source_next?(true),
          source_next(job_a),
          with(var_active_jobs, active_jobs),
          add_job(job_a),
          send_value(payload_a),
          new_deadline,
          read_response(job_a, response_a),
          with(var_active_jobs, active_jobs),
          remove_job(job_a),
          with(var_sink, sink),
          sink_response(response_a),
          sink_stop?(false),
          with(var_source, source),
          source_next?(true),
          source_next(job_b),
          with(var_active_jobs, active_jobs),
          add_job(job_b),
          send_value(payload_b),
          new_deadline,
          read_response(job_b, response_b),
          with(var_active_jobs, active_jobs),
          remove_job(job_b),
          with(var_sink, sink),
          sink_response(response_b),
          sink_stop?(true),
          *finalize
        ]
      end

      include_examples 'worker execution'
    end

    context 'when processing jobs till error' do
      let(:response_a) do
        Mutant::Parallel::Response.new(
          error:  Timeout::Error,
          job:    0,
          log:    'log',
          result: nil
        )
      end

      let(:raw_expectations) do
        [
          with(var_source, source),
          source_next?(true),
          source_next(job_a),
          with(var_active_jobs, active_jobs),
          add_job(job_a),
          send_value(payload_a),
          new_deadline,
          read_response(job_a, response_a),
          with(var_active_jobs, active_jobs),
          remove_job(job_a),
          with(var_sink, sink),
          sink_response(response_a),
          sink_stop?(false),
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
    def apply
      subject.join
    end

    let(:raw_expectations) do
      [
        {
          receiver:  world.process,
          selector:  :wait,
          arguments: [pid]
        }
      ]
    end

    it 'terminates and waits for process' do
      verify_events { expect(apply).to be(subject) }
    end
  end

  describe '#signal' do
    def apply
      subject.signal
    end

    let(:raw_expectations) do
      [
        {
          receiver:  world.process,
          selector:  :kill,
          arguments: ['TERM', pid]
        }
      ]
    end

    it 'terminates and waits for process' do
      verify_events { expect(apply).to be(subject) }
    end
  end

  describe '.start' do
    let(:child_connection)   { instance_double(Mutant::Parallel::Connection) }
    let(:forked_main_thread) { instance_double(Thread) }

    # rubocop:disable Metrics/MethodLength
    def apply
      described_class.start(
        block:            block,
        index:            index,
        on_process_start: on_process_start,
        process_name:     process_name,
        timeout:          1.0,
        var_active_jobs:  var_active_jobs,
        var_final:        var_final,
        var_running:      var_running,
        var_sink:         var_sink,
        var_source:       var_source,
        world:            world
      )
    end
    # rubocop:enable Metrics/MethodLength

    let(:raw_expectations) do
      [
        {
          receiver:  Mutant::Parallel::Pipe,
          selector:  :from_io,
          arguments: [world.io],
          reaction:  { return: log_pipe }
        },
        {
          receiver:  Mutant::Parallel::Pipe,
          selector:  :from_io,
          arguments: [world.io],
          reaction:  { return: request_pipe }
        },
        {
          receiver:  Mutant::Parallel::Pipe,
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
          receiver:  world.stderr,
          selector:  :reopen,
          arguments: [log_pipe.to_writer]
        },
        {
          receiver:  world.stdout,
          selector:  :reopen,
          arguments: [log_pipe.to_writer]
        },
        {
          receiver:  Mutant::Parallel::Connection,
          selector:  :from_pipes,
          arguments: [{ marshal: world.marshal, reader: request_pipe, writer: response_pipe }],
          reaction:  { return: child_connection }
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
          receiver:  on_process_start,
          selector:  :call,
          arguments: [{ index: index }]
        },
        {
          receiver: child_connection,
          selector: :receive_value,
          reaction: { return: 1 }
        },
        {
          receiver: log_pipe.to_writer,
          selector: :flush
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
          receiver:  Mutant::Parallel::Connection,
          selector:  :from_pipes,
          arguments: [{ marshal: world.marshal, reader: response_pipe, writer: request_pipe }],
          reaction:  { return: parent_connection }
        }
      ]
    end

    let(:expected_worker) do
      subject.with(connection: parent_connection)
    end

    it 'starts worker (process)' do
      verify_events { expect(apply).to eql(expected_worker) }
    end
  end
end
