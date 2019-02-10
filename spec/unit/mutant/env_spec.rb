# frozen_string_literal: true

RSpec.describe Mutant::Env do
  subject do
    described_class.new(
      config:           config,
      integration:      integration,
      matchable_scopes: [],
      mutations:        [],
      selector:         selector,
      subjects:         [mutation_subject],
      parser:           Mutant::Parser.new,
      world:            world
    )
  end

  let(:integration)       { instance_double(Mutant::Integration) }
  let(:integration_class) { Mutant::Integration::Null            }
  let(:isolation)         { Mutant::Isolation::None.new          }
  let(:kernel)            { instance_double(Object, 'kernel')    }
  let(:mutation_subject)  { instance_double(Mutant::Subject)     }
  let(:reporter)          { instance_double(Mutant::Reporter)    }
  let(:selector)          { instance_double(Mutant::Selector)    }
  let(:test_a)            { instance_double(Mutant::Test)        }
  let(:test_b)            { instance_double(Mutant::Test)        }
  let(:tests)             { [test_a, test_b]                     }

  let(:mutation) do
    instance_double(
      Mutant::Mutation,
      subject: mutation_subject
    )
  end

  let(:config) do
    instance_double(
      Mutant::Config,
      integration: integration_class,
      isolation:   isolation,
      reporter:    reporter
    )
  end

  let(:world) do
    instance_double(
      Mutant::World,
      kernel: kernel
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
      subject.kill(mutation)
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
        expect(mutation).to have_received(:insert).ordered.with(kernel)
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
        expect(mutation).to have_received(:insert).ordered.with(kernel)
      end

      include_examples 'mutation kill'
    end
  end

  describe '#selections' do
    def apply
      subject.selections
    end

    it 'returns expected selections' do
      expect(apply).to eql(mutation_subject => tests)
    end
  end

  describe '#warn' do
    def apply
      subject.warn(message)
    end

    before do
      allow(reporter).to receive_messages(warn: reporter)
    end

    let(:message) { 'test-warning' }

    it 'warns via the reporter' do
      apply

      expect(reporter).to have_received(:warn).with(message)
    end

    it 'returns self' do
      expect(apply).to be(subject)
    end
  end
end
