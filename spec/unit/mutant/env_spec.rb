# frozen_string_literal: true

RSpec.describe Mutant::Env do
  let(:object) do
    described_class.new(
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
    def apply
      object.kill(mutation)
    end

    before do
      allow(isolation).to receive(:call) do |&block|
        Mutant::Isolation::Result::Success.new(block.call)
      end

      allow(mutation).to receive_messages(insert: loader_result)
    end

    shared_examples 'mutation kill' do
      it 'returns expected result' do
        expect(apply).to eql(
          Mutant::Result::Mutation.new(
            isolation_result: isolation_result,
            mutation:         mutation,
            runtime:          1.0
          )
        )
      end
    end

    context 'when loader is successful' do
      let(:loader_result) { Mutant::Loader::Result::Success.instance }
      let(:test_result)   { instance_double(Mutant::Result::Test)    }

      let(:isolation_result) do
        Mutant::Isolation::Result::Success.new(test_result)
      end

      before do
        allow(integration).to receive_messages(call: test_result)
      end

      it 'performs IO in expected sequence' do
        apply

        expect(isolation).to have_received(:call).ordered
        expect(mutation).to have_received(:insert).ordered.with(config.kernel)
        expect(integration).to have_received(:call).ordered.with(tests)
      end

      include_examples 'mutation kill'
    end

    context 'when loader reports void value' do
      let(:loader_result) { Mutant::Loader::Result::VoidValue.instance }

      let(:isolation_result) do
        Mutant::Isolation::Result::Success.new(Mutant::Result::Test::VoidValue.instance)
      end

      it 'performs IO in expected sequence' do
        apply

        expect(isolation).to have_received(:call).ordered
        expect(mutation).to have_received(:insert).ordered.with(config.kernel)
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
