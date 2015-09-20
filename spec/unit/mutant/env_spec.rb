RSpec.describe Mutant::Env do
  let(:integration_class) { Mutant::Integration::Null            }
  let(:integration)       { instance_double(Mutant::Integration) }
  let(:isolation)         { double(Mutant::Isolation)            }
  let(:selector)          { instance_double(Mutant::Selector)    }

  let(:object) do
    described_class.new(
      actor_env:         Mutant::Actor::Env.new(Thread),
      cache:             Mutant::Cache.new,
      config:            config,
      expression_parser: Mutant::Expression::Parser::DEFAULT,
      integration:       integration,
      isolation:         isolation,
      matchable_scopes:  [],
      mutations:         [],
      selector:          selector,
      subjects:          []
    )
  end

  let(:config) do
    Mutant::Config::DEFAULT.with(
      integration: integration_class,
      reporter:    Mutant::Reporter::Trace.new
    )
  end

  describe '#warn' do
    let(:message) { instance_double(String) }

    subject { object.warn(message) }

    it 'reports a warning' do
      expect { subject }
        .to change { object.config.reporter.warn_calls }
        .from([])
        .to([message])
    end

    it_behaves_like 'a command method'
  end

  describe '#kill' do
    subject { object.kill(mutation) }

    let(:mutation)          { instance_double(Mutant::Mutation, subject: mutation_subject) }
    let(:test_a)            { instance_double(Mutant::Test)                                }
    let(:test_b)            { instance_double(Mutant::Test)                                }
    let(:tests)             { [test_a, test_b]                                             }

    let(:mutation_subject) do
      instance_double(
        Mutant::Subject,
        identification: 'subject',
        source:         'original'
      )
    end

    shared_examples_for 'mutation kill' do
      it { should eql(Mutant::Result::Mutation.new(mutation: mutation, test_result: test_result)) }
    end

    before do
      expect(selector).to receive(:call).with(mutation_subject).and_return(tests)
      allow(Time).to receive(:now).and_return(Time.at(0))
    end

    context 'when isolation does not raise error' do
      let(:test_result) { instance_double(Mutant::Result::Test, passed: false) }

      before do
        expect(isolation).to receive(:call)
          .ordered
          .and_yield
          .and_return(test_result)

        expect(mutation).to receive(:insert)
          .ordered
          .and_return(mutation)

        expect(integration).to receive(:call)
          .ordered
          .with(tests)
          .and_return(test_result)
      end

      include_examples 'mutation kill'
    end

    context 'when isolation does raise error' do
      before do
        expect(isolation).to receive(:call).and_raise(Mutant::Isolation::Error, 'test-error')
      end

      let(:test_result) { Mutant::Result::Test.new(tests: tests, output: 'test-error', passed: false, runtime: 0.0) }

      include_examples 'mutation kill'
    end
  end
end
