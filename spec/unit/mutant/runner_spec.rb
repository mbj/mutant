RSpec.describe Mutant::Runner do
  describe '.call' do
    let(:integration) { instance_double(Mutant::Integration)            }
    let(:reporter)    { instance_double(Mutant::Reporter, delay: delay) }
    let(:driver)      { instance_double(Mutant::Parallel::Driver)       }
    let(:delay)       { instance_double(Float)                          }
    let(:env)         { instance_double(Mutant::Env, mutations: [])     }
    let(:env_result)  { instance_double(Mutant::Result::Env)            }
    let(:actor_env)   { instance_double(Mutant::Actor::Env)             }

    let(:config) do
      instance_double(
        Mutant::Config,
        integration: integration,
        jobs:        1,
        reporter:    reporter
      )
    end

    before do
      allow(env).to receive_messages(config: config, actor_env: actor_env)
      allow(env).to receive(:method).with(:kill).and_return(parallel_config.processor)
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

    context 'when runner finishes immediately' do
      let(:status) { instance_double(Mutant::Parallel::Status, done: true, payload: env_result) }

      before do
        expect(driver).to receive(:status).and_return(status)
        expect(reporter).to receive(:progress).with(status).ordered
        expect(driver).to receive(:stop).ordered
        expect(reporter).to receive(:report).with(env_result).ordered
      end
    end

    context 'when report iterations are done' do
      let(:status_a) { instance_double(Mutant::Parallel::Status, done: false)                     }
      let(:status_b) { instance_double(Mutant::Parallel::Status, done: true, payload: env_result) }

      before do
        expect(driver).to receive(:status).and_return(status_a).ordered
        expect(reporter).to receive(:progress).with(status_a).ordered
        expect(Kernel).to receive(:sleep).with(reporter.delay).ordered

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
