# frozen_string_literal: true

RSpec.describe Mutant::Runner do
  describe '.call' do
    let(:condition_variable) { class_double(ConditionVariable)                 }
    let(:delay)              { instance_double(Float)                          }
    let(:driver)             { instance_double(Mutant::Parallel::Driver)       }
    let(:env_result)         { instance_double(Mutant::Result::Env)            }
    let(:kernel)             { class_double(Kernel)                            }
    let(:mutex)              { class_double(Mutex)                             }
    let(:processor)          { instance_double(Method)                         }
    let(:reporter)           { instance_double(Mutant::Reporter, delay: delay) }
    let(:thread)             { class_double(Thread)                            }

    let(:env) do
      instance_double(
        Mutant::Env,
        config:    config,
        mutations: [],
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

    let(:world) do
      instance_double(
        Mutant::World,
        condition_variable: condition_variable,
        kernel:             kernel,
        mutex:              mutex,
        thread:             thread,
        timer:              timer
      )
    end

    let(:timer) do
      instance_double(
        Mutant::Timer,
        now: 1.0
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
        condition_variable: condition_variable,
        jobs:               1,
        mutex:              mutex,
        processor:          processor,
        sink:               Mutant::Runner::Sink.new(env),
        source:             Mutant::Parallel::Source::Array.new(env.mutations),
        thread:             thread
      )
    end

    def apply
      described_class.apply(env)
    end

    let(:raw_expectations) do
      [
        {
          receiver:  reporter,
          selector:  :start,
          arguments: [env]
        },
        {
          receiver:  env,
          selector:  :method,
          arguments: [:kill],
          reaction:  { return: processor }
        },
        {
          receiver:  Mutant::Parallel,
          selector:  :async,
          arguments: [parallel_config],
          reaction:  { return: driver }
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
