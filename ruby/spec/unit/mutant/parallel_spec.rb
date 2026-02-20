# frozen_string_literal: true

RSpec.describe Mutant::Parallel do
  describe '.async' do
    def apply
      described_class.async(config:, world:)
    end

    let(:block)            { instance_double(Proc)                                 }
    let(:jobs)             { 2                                                     }
    let(:on_process_start) { instance_double(Proc)                                 }
    let(:sink)             { instance_double(described_class::Sink)                }
    let(:source)           { instance_double(described_class::Source)              }
    let(:thread_a)         { instance_double(Thread)                               }
    let(:thread_b)         { instance_double(Thread)                               }
    let(:var_active_jobs)  { instance_double(Mutant::Variable::IVar, :active_jobs) }
    let(:var_final)        { instance_double(Mutant::Variable::IVar, :final)       }
    let(:var_running)      { instance_double(Mutant::Variable::MVar, :running)     }
    let(:var_sink)         { instance_double(Mutant::Variable::IVar, :sink)        }
    let(:var_source)       { instance_double(Mutant::Variable::IVar, :source)      }

    let(:world) do
      instance_double(
        Mutant::World,
        condition_variable: class_double(ConditionVariable),
        mutex:              class_double(Mutex),
        thread:             class_double(Thread)
      )
    end

    let(:worker_a) do
      instance_double(described_class::Worker, :a, index: 0)
    end

    let(:worker_b) do
      instance_double(described_class::Worker, :b, index: 1)
    end

    let(:config) do
      Mutant::Parallel::Config.new(
        block:,
        jobs:,
        on_process_start:,
        process_name:     'parallel-process',
        sink:,
        source:,
        thread_name:      'parallel-thread',
        timeout:          1.0
      )
    end

    def ivar(value, **attributes)
      {
        receiver:  Mutant::Variable::IVar,
        selector:  :new,
        arguments: [{
          condition_variable: world.condition_variable,
          mutex:              world.mutex,
          **attributes
        }],
        reaction:  { return: value }
      }
    end

    def mvar(value, **arguments)
      ivar(value, **arguments).merge(receiver: Mutant::Variable::MVar)
    end

    # rubocop:disable Metrics/MethodLength
    def worker(index, name, worker)
      {
        receiver:  Mutant::Parallel::Worker,
        selector:  :start,
        arguments: [
          {
            block:,
            index:,
            on_process_start: config.on_process_start,
            process_name:     name,
            timeout:          1.0,
            var_active_jobs:,
            var_final:,
            var_running:,
            var_sink:,
            var_source:,
            world:
          }
        ],
        reaction:  { return: worker }
      }
    end

    def thread(name, thread, worker)
      [
        {
          receiver: world.thread,
          selector: :new,
          reaction: { yields: [], return: thread }
        },
        {
          receiver: world.thread,
          selector: :current,
          reaction: { return: thread }
        },
        {
          receiver:  thread,
          selector:  :name=,
          arguments: [name]
        },
        {
          receiver: worker,
          selector: :call
        }
      ]
    end

    let(:raw_expectations) do
      [
        ivar(var_active_jobs, value: Set.new),
        ivar(var_final),
        mvar(var_running, value: 2),
        ivar(var_sink, value: sink),
        ivar(var_source, value: source),
        {
          receiver:  world,
          selector:  :process_warmup,
          arguments: []
        },
        worker(0, 'parallel-process-0', worker_a),
        worker(1, 'parallel-process-1', worker_b),
        *thread('parallel-thread-0', thread_a, worker_a),
        *thread('parallel-thread-1', thread_b, worker_b)
      ]
    end

    it 'returns driver' do
      verify_events do
        expect(apply).to eql(
          described_class::Driver.new(
            threads:         [thread_a, thread_b],
            var_active_jobs:,
            var_final:,
            var_running:,
            var_sink:,
            var_source:,
            workers:         [worker_a, worker_b]
          )
        )
      end
    end
  end
end
