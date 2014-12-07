RSpec.describe Mutant::Runner do
  # setup_shared_context
  class FakeEnv
    def self.kill
    end

    def self.mutations
      []
    end
  end

  skip '.call' do
    let(:integration) { double('Integration')            }
    let(:reporter)    { double('Reporter', delay: delay) }
    let(:driver)      { double('Driver')                 }
    let(:delay)       { double('Delay')                  }
    let(:env)         { FakeEnv                          }
    let(:env_result)  { double('Env Result')             }
    let(:actor_env)   { double('Actor ENV')              }

    let(:config) do
      double(
        'Config',
        integration: integration,
        reporter:    reporter,
        actor_env:   actor_env,
        jobs:        1
      )
    end

    before do
      allow(FakeEnv).to receive(:config).and_return(config)
      allow(FakeEnv).to receive(:actor_env).and_return(actor_env)
    end

    let(:parallel_config) do
      Mutant::Parallel::Config.new(
        jobs:      1,
        env:       actor_env,
        source:    Mutant::Parallel::Source::Array.new(env.mutations),
        sink:      Mutant::Runner::Sink::Mutation.new(env),
        processor: env.method(:kill)
      )
    end

    before do
      expect(reporter).to receive(:start).with(env).ordered
      expect(integration).to receive(:setup).ordered
      expect(Mutant::Parallel).to receive(:async).with(parallel_config).and_return(driver).ordered
    end

    subject { described_class.call(env) }

    context 'when runner finishes immediately' do
      let(:status) { double('Status', done: true, payload: env_result) }

      before do
        expect(driver).to receive(:status).and_return(status)
        expect(reporter).to receive(:progress).with(status).ordered
        expect(driver).to receive(:stop).ordered
        expect(reporter).to receive(:report).with(env_result).ordered
      end
    end

    context 'when report iterations are done' do
      let(:status_a) { double('Status A', done: false)                     }
      let(:status_b) { double('Status B', done: true, payload: env_result) }

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
