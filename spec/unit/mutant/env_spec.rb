# frozen_string_literal: true

RSpec.describe Mutant::Env do
  let(:object) do
    described_class.new(
      actor_env:        Mutant::Actor::Env.new(Thread),
      config:           config,
      integration:      integration,
      matchable_scopes: [],
      mutations:        [],
      selector:         selector,
      subjects:         [mutation_subject],
      parser:           Mutant::Parser.new
    )
  end

  let(:integration)       { instance_double(Mutant::Integration) }
  let(:test_a)            { instance_double(Mutant::Test)        }
  let(:test_b)            { instance_double(Mutant::Test)        }
  let(:tests)             { [test_a, test_b]                     }
  let(:selector)          { instance_double(Mutant::Selector)    }
  let(:integration_class) { Mutant::Integration::Null            }
  let(:isolation)         { Mutant::Isolation::None.new          }
  let(:mutation_subject)  { instance_double(Mutant::Subject)     }

  let(:mutation) do
    instance_double(
      Mutant::Mutation,
      subject: mutation_subject
    )
  end

  let(:config) do
    Mutant::Config::DEFAULT.with(
      isolation:   isolation,
      integration: integration_class,
      kernel:      class_double(Kernel)
    )
  end

  before do
    allow(selector).to receive(:call)
      .with(mutation_subject)
      .and_return(tests)

    allow(Mutant::Timer).to receive(:now).and_return(2.0, 3.0)
  end

  describe '#kill' do
    subject { object.kill(mutation) }

    shared_examples_for 'mutation kill' do
      specify do
        should eql(
          Mutant::Result::Mutation.new(
            isolation_result: isolation_result,
            mutation:         mutation,
            runtime:          1.0
          )
        )
      end
    end

    context 'when isolation does not raise error' do
      let(:test_result) { instance_double(Mutant::Result::Test) }

      before do
        expect(mutation).to receive(:insert)
          .ordered
          .with(config.kernel)

        expect(integration).to receive(:call)
          .ordered
          .with(tests)
          .and_return(test_result)
      end

      let(:isolation_result) do
        Mutant::Isolation::Result::Success.new(test_result)
      end

      include_examples 'mutation kill'
    end

    context 'when code does raise error' do
      let(:exception) { RuntimeError.new('foo') }

      before do
        expect(mutation).to receive(:insert).and_raise(exception)
      end

      let(:isolation_result) do
        Mutant::Isolation::Result::Exception.new(exception)
      end

      include_examples 'mutation kill'
    end
  end

  describe '#selections' do
    subject { object.selections }

    it 'returns expected selections' do
      expect(subject).to eql(mutation_subject => tests)
    end
  end
end
