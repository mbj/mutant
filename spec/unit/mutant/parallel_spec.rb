# frozen_string_literal: true

RSpec.describe Mutant::Parallel do
  describe '.async' do
    def apply
      described_class.async(world, config)
    end

    let(:block)           { instance_double(Proc)                         }
    let(:jobs)            { 2                                             }
    let(:sink)            { instance_double(described_class::Sink)        }
    let(:source)          { instance_double(described_class::Source)      }
    let(:thread_a)        { instance_double(Thread)                       }
    let(:thread_b)        { instance_double(Thread)                       }
    let(:var_active_jobs) { instance_double(Variable::IVar, :active_jobs) }
    let(:var_final)       { instance_double(Variable::IVar, :final)       }
    let(:var_running)     { instance_double(Variable::MVar, :running)     }
    let(:var_sink)        { instance_double(Variable::IVar, :sink)        }
    let(:var_source)      { instance_double(Variable::IVar, :source)      }
    let(:world)           { fake_world                                    }

    let(:worker_a) do
      instance_double(described_class::Worker, :a, index: 0)
    end

    let(:worker_b) do
      instance_double(described_class::Worker, :b, index: 1)
    end

    let(:config) do
      Mutant::Parallel::Config.new(
        block:        block,
        jobs:         jobs,
        process_name: 'parallel-process',
        sink:         sink,
        source:       source,
        thread_name:  'parallel-thread'
      )
    end

    def ivar(value, **attributes)
      {
        receiver:  Variable::IVar,
        selector:  :new,
        arguments: [
          condition_variable: world.condition_variable,
          mutex:              world.mutex,
          **attributes
        ],
        reaction:  { return: value }
      }
    end

    def mvar(value, **arguments)
      ivar(value, **arguments).merge(receiver: Variable::MVar)
    end

    # rubocop:disable Metrics/MethodLength
    def worker(index, name, worker)
      {
        receiver:  Mutant::Parallel::Worker,
        selector:  :start,
        arguments: [
          block:           block,
          index:           index,
          process_name:    name,
          world:           world,
          var_active_jobs: var_active_jobs,
          var_final:       var_final,
          var_running:     var_running,
          var_sink:        var_sink,
          var_source:      var_source
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
            var_active_jobs: var_active_jobs,
            var_final:       var_final,
            var_running:     var_running,
            var_sink:        var_sink,
            var_source:      var_source,
            workers:         [worker_a, worker_b]
          )
        )
      end
    end
  end
end
