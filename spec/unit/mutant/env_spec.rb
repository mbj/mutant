# frozen_string_literal: true

RSpec.describe Mutant::Env do
  subject do
    described_class.new(
      config:           config,
      integration:      integration,
      matchable_scopes: [],
      mutations:        [],
      selector:         selector,
      subjects:         [subject_a, subject_b],
      parser:           Mutant::Parser.new,
      world:            world
    )
  end

  let(:integration_class) { Mutant::Integration::Null                 }
  let(:isolation)         { Mutant::Isolation::None.new               }
  let(:kernel)            { instance_double(Object, 'kernel')         }
  let(:reporter)          { instance_double(Mutant::Reporter)         }
  let(:selector)          { instance_double(Mutant::Selector)         }
  let(:subject_a)         { instance_double(Mutant::Subject, :a)      }
  let(:subject_b)         { instance_double(Mutant::Subject, :b)      }
  let(:test_a)            { instance_double(Mutant::Test, :a)         }
  let(:test_b)            { instance_double(Mutant::Test, :b)         }
  let(:test_c)            { instance_double(Mutant::Test, :c)         }
  let(:selector_result_a) { Mutant::Maybe::Just.new([test_a, test_b]) }
  let(:selector_result_b) { Mutant::Maybe::Just.new([test_b, test_c]) }

  let(:integration) do
    instance_double(Mutant::Integration, all_tests: [test_a, test_b, test_c])
  end

  let(:mutation) do
    instance_double(
      Mutant::Mutation,
      subject: subject_a
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
      .with(subject_a)
      .and_return(selector_result_a)

    allow(selector).to receive(:call)
      .with(subject_b)
      .and_return(selector_result_b)

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
        expect(integration).to have_received(:call).ordered.with([test_a, test_b])
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

    context 'when selector returns values' do
      it 'returns expected selections' do
        expect(apply).to eql(
          subject_a => [test_a, test_b],
          subject_b => [test_b, test_c]
        )
      end
    end

    context 'when selector fails to return values' do
      let(:selector_result_a) { Mutant::Maybe::Nothing.new }
      let(:selector_result_b) { Mutant::Maybe::Nothing.new }

      it 'returns expected selections' do
        expect(apply).to eql(subject_a => [], subject_b => [])
      end
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

  describe '#amount_mutations' do
    def apply
      subject.amount_mutations
    end

    it 'returns expected value' do
      expect(apply).to be(0)
    end
  end

  describe '#amount_total_tests' do
    def apply
      subject.amount_total_tests
    end

    it 'returns expected value' do
      expect(apply).to be(3)
    end
  end

  describe '#test_subject_ratio' do
    def apply
      subject.test_subject_ratio
    end

    let(:subjects) { [subject_a, instance_double(Mutant::Subject)] }

    it 'returns expected value' do
      expect(apply).to eql(Rational(3, 2))
    end
  end

  describe '.empty' do
    def apply
      described_class.empty(world, config)
    end

    it 'returns empty env' do
      expect(apply).to eql(
        described_class.new(
          config:           config,
          integration:      Mutant::Integration::Null.new(config),
          matchable_scopes: Mutant::EMPTY_ARRAY,
          mutations:        Mutant::EMPTY_ARRAY,
          parser:           Mutant::Parser.new,
          selector:         Mutant::Selector::Null.new,
          subjects:         Mutant::EMPTY_ARRAY,
          world:            world
        )
      )
    end
  end
end
