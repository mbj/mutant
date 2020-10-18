# frozen_string_literal: true

RSpec.describe Mutant::Parallel do
  describe '.async' do
    def apply
      described_class.async(config)
    end

    let(:condition_variable) { class_double(ConditionVariable)          }
    let(:jobs)               { 2                                        }
    let(:mutex)              { class_double(Mutex)                      }
    let(:processor)          { instance_double(Proc)                    }
    let(:sink)               { instance_double(described_class::Sink)   }
    let(:source)             { instance_double(described_class::Source) }
    let(:thread)             { class_double(Thread)                     }
    let(:thread_a)           { instance_double(Thread)                  }
    let(:thread_b)           { instance_double(Thread)                  }
    let(:worker)             { -> {}                                    }

    let(:config) do
      Mutant::Parallel::Config.new(
        condition_variable: condition_variable,
        jobs:               jobs,
        mutex:              mutex,
        processor:          processor,
        sink:               sink,
        source:             source,
        thread:             thread
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

    def ivar(value, **attributes)
      {
        receiver:  Variable::IVar,
        selector:  :new,
        arguments: [
          condition_variable: condition_variable,
          mutex:              mutex,
          **attributes
        ],
        reaction:  { return: value }
      }
    end

    def mvar(value, **arguments)
      ivar(value, **arguments).merge(receiver: Variable::MVar)
    end

    let(:raw_expectations) do
      [
        ivar(var_active_jobs, value: Set.new),
        ivar(var_final),
        ivar(var_sink, value: sink),
        mvar(var_running, value: 2),
        ivar(var_source, value: source),
        {
          receiver:  Mutant::Parallel::Worker,
          selector:  :new,
          arguments: [
            processor:       processor,
            var_active_jobs: var_active_jobs,
            var_final:       var_final,
            var_running:     var_running,
            var_sink:        var_sink,
            var_source:      var_source
          ],
          reaction:  { return: worker }
        },
        {
          receiver: thread,
          selector: :new,
          reaction: { yields: [], return: thread_a }
        },
        {
          receiver: thread,
          selector: :new,
          reaction: { yields: [], return: thread_b }
        }
      ]
    end

    it 'returns driver' do
      verify_events do
        expect(apply).to eql(
          described_class::Driver.new(
            threads:         [thread_a, thread_b],
            var_active_jobs: var_active_jobs,
            var_final:       var_final,
            var_sink:        var_sink
          )
        )
      end
    end
  end
end
