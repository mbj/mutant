# frozen_string_literal: true

RSpec.describe Mutant::Runner do
  describe '.call' do
    let(:reporter)    { instance_double(Mutant::Reporter, delay: delay) }
    let(:driver)      { instance_double(Mutant::Parallel::Driver)       }
    let(:delay)       { instance_double(Float)                          }
    let(:env_result)  { instance_double(Mutant::Result::Env)            }
    let(:actor_env)   { instance_double(Mutant::Actor::Env)             }
    let(:kernel)      { class_double(Kernel)                            }
    let(:sleep)       { instance_double(Method)                         }

    let(:env) do
      instance_double(
        Mutant::Env,
        actor_env: actor_env,
        config:    config,
        mutations: []
      )
    end

    let(:config) do
      instance_double(
        Mutant::Config,
        jobs:     1,
        kernel:   kernel,
        reporter: reporter
      )
    end

    before do
      allow(env).to receive(:method).with(:kill).and_return(parallel_config.processor)
      allow(kernel).to receive(:method).with(:sleep).and_return(sleep)
    end

    let(:parallel_config) do
      Mutant::Parallel::Config.new(
        env:       actor_env,
        jobs:      1,
        processor: ->(_object) { fail },
        sink:      Mutant::Runner::Sink.new(env),
        source:    Mutant::Parallel::Source::Array.new(env.mutations)
      )
    end

    before do
      expect(reporter).to receive(:start).with(env).ordered
      expect(Mutant::Parallel).to receive(:async).with(parallel_config).and_return(driver).ordered
    end

    subject { described_class.call(env) }

    context 'when report iterations are done' do
      let(:status_a) { instance_double(Mutant::Parallel::Status, done: false)                     }
      let(:status_b) { instance_double(Mutant::Parallel::Status, done: true, payload: env_result) }

      before do
        expect(driver).to receive(:status).and_return(status_a).ordered
        expect(reporter).to receive(:progress).with(status_a).ordered
        expect(sleep).to receive(:call).with(reporter.delay).ordered

        expect(driver).to receive(:status).and_return(status_b).ordered
        expect(reporter).to receive(:progress).with(status_b).ordered
        expect(driver).to receive(:stop).ordered

        expect(reporter).to receive(:report).with(env_result).ordered
      end

      it 'returns env result' do
        should be(env_result)
      end
    end
  end
end
