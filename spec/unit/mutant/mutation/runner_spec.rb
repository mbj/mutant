# frozen_string_literal: true

RSpec.describe Mutant::Mutation::Runner do
  describe '.call' do
    let(:block)                              { instance_double(Proc)                           }
    let(:delay)                              { instance_double(Float)                          }
    let(:driver)                             { instance_double(Mutant::Parallel::Driver)       }
    let(:emit_mutation_worker_process_start) { instance_double(Proc)                           }
    let(:env_result)                         { instance_double(Mutant::Result::Env)            }
    let(:reporter)                           { instance_double(Mutant::Reporter, delay: delay) }
    let(:world)                              { instance_double(Mutant::World)                  }
    let(:timer)                              { instance_double(Mutant::Timer)                  }

    let(:env) do
      instance_double(
        Mutant::Env,
        config:    config,
        mutations: [instance_double(Mutant::Mutation)],
        world:     world
      )
    end

    let(:config) do
      instance_double(
        Mutant::Config,
        jobs:     1,
        reporter: reporter
      )
    end

    let(:status_a) do
      instance_double(
        Mutant::Parallel::Status,
        done?: false
      )
    end

    let(:status_b) do
      instance_double(
        Mutant::Parallel::Status,
        done?:   true,
        payload: env_result
      )
    end

    let(:parallel_config) do
      Mutant::Parallel::Config.new(
        block:            block,
        jobs:             1,
        on_process_start: emit_mutation_worker_process_start,
        process_name:     'mutant-worker-process',
        sink:             described_class::Sink.new(env: env),
        source:           Mutant::Parallel::Source::Array.new(jobs: env.mutations.each_index.to_a),
        thread_name:      'mutant-worker-thread',
        timeout:          nil
      )
    end

    before do
      allow(world).to receive_messages(timer: timer)
      allow(world.timer).to receive_messages(now: 1.0)
    end

    def apply
      described_class.call(env)
    end

    context 'when not stopped' do
      let(:raw_expectations) do
        [
          {
            receiver:  reporter,
            selector:  :start,
            arguments: [env]
          },
          {
            receiver:  env,
            selector:  :record,
            arguments: [:analysis],
            reaction:  { yields: [] }
          },
          {
            receiver:  env,
            selector:  :method,
            arguments: [:cover_index],
            reaction:  { return: block }
          },
          {
            receiver:  env,
            selector:  :method,
            arguments: [:emit_mutation_worker_process_start],
            reaction:  { return: emit_mutation_worker_process_start }
          },
          {
            receiver:  Mutant::Parallel,
            selector:  :async,
            arguments: [{ world: world, config: parallel_config }],
            reaction:  { return: driver }
          },
          {
            receiver:  Signal,
            selector:  :trap,
            arguments: ['INT']
          },
          {
            receiver:  driver,
            selector:  :wait_timeout,
            arguments: [delay],
            reaction:  { return: status_a }
          },
          {
            receiver:  reporter,
            selector:  :progress,
            arguments: [status_a]
          },
          {
            receiver:  driver,
            selector:  :wait_timeout,
            arguments: [delay],
            reaction:  { return: status_b }
          },
          {
            receiver:  env,
            selector:  :record,
            arguments: [:report],
            reaction:  { yields: [] }
          },
          {
            receiver:  reporter,
            selector:  :report,
            arguments: [env_result]
          }
        ]
      end

      before do
        allow(driver).to receive_messages(stop: driver)
      end

      it 'returns env result' do
        verify_events { expect(apply).to eql(Mutant::Either::Right.new(env_result)) }
      end
    end

    context 'when stopped' do
      let(:raw_expectations) do
        [
          {
            receiver:  reporter,
            selector:  :start,
            arguments: [env]
          },
          {
            receiver:  env,
            selector:  :record,
            arguments: [:analysis],
            reaction:  { yields: [] }
          },
          {
            receiver:  env,
            selector:  :method,
            arguments: [:cover_index],
            reaction:  { return: block }
          },
          {
            receiver:  env,
            selector:  :method,
            arguments: [:emit_mutation_worker_process_start],
            reaction:  { return: emit_mutation_worker_process_start }
          },
          {
            receiver:  Mutant::Parallel,
            selector:  :async,
            arguments: [{ world: world, config: parallel_config }],
            reaction:  { return: driver }
          },
          {
            receiver:  Signal,
            selector:  :trap,
            arguments: ['INT'],
            reaction:  { yields: [] }
          },
          {
            receiver: driver,
            selector: :stop
          },
          {
            receiver:  driver,
            selector:  :wait_timeout,
            arguments: [delay],
            reaction:  { return: status_a }
          },
          {
            receiver:  reporter,
            selector:  :progress,
            arguments: [status_a]
          },
          {
            receiver:  driver,
            selector:  :wait_timeout,
            arguments: [delay],
            reaction:  { return: status_b }
          },
          {
            receiver:  env,
            selector:  :record,
            arguments: [:report],
            reaction:  { yields: [] }
          },
          {
            receiver:  reporter,
            selector:  :report,
            arguments: [env_result]
          }
        ]
      end

      it 'returns env result' do
        verify_events { expect(apply).to eql(Mutant::Either::Right.new(env_result)) }
      end
    end
  end
end
