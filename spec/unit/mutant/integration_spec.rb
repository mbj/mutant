# frozen_string_literal: true

RSpec.describe Mutant::Integration do
  let(:object) do
    Class.new(described_class).new(
      expression_parser: expression_parser,
      timer:             timer
    )
  end

  let(:expression_parser) { instance_double(Mutant::Expression::Parser) }
  let(:timer)             { instance_double(Mutant::Timer)              }

  describe '#setup' do
    def apply
      object.setup
    end

    it 'returns self' do
      expect(apply).to be(object)
    end
  end

  describe '.setup' do
    def apply
      described_class.setup(env)
    end

    let(:kernel)           { class_double(Kernel)                       }
    let(:integration)      { instance_double(Mutant::Integration::Null) }
    let(:integration_name) { 'null'                                     }

    let(:config) do
      instance_double(
        Mutant::Config,
        integration:       integration_name,
        expression_parser: expression_parser
      )
    end

    let(:env) do
      instance_double(
        Mutant::Env,
        config: config,
        world:  world
      )
    end

    let(:world) do
      instance_double(
        Mutant::World,
        kernel: kernel,
        timer:  timer
      )
    end

    before do
      allow(kernel).to receive_messages(require: undefined)
      allow(described_class).to receive_messages(const_get: described_class::Null)
      allow(described_class::Null).to receive_messages(new: integration)
      allow(integration).to receive_messages(setup: integration)
    end

    context 'when require fails' do
      let(:exception) { LoadError.new('some-load-error') }

      before do
        allow(kernel).to receive(:require).and_raise(exception)
      end

      it 'returns error' do
        expect(apply).to eql(Mutant::Either::Left.new(<<~MESSAGE))
          Unable to load integration mutant-null:
          #{exception.inspect}
          You may have to install the gem mutant-null!
        MESSAGE
      end
    end

    context 'when constant lookup fails' do
      let(:exception) { NameError.new('some-name-error') }

      before do
        allow(described_class).to receive(:const_get).and_raise(exception)
      end

      it 'returns error' do
        expect(apply).to eql(Mutant::Either::Left.new(<<~MESSAGE))
          Unable to load integration mutant-null:
          #{exception.inspect}
          This is a bug in the integration you have to report.
          The integration is supposed to define Mutant::Integration::Null!
        MESSAGE
      end
    end

    it 'performs actions in expected sequence' do
      apply

      expect(kernel)
        .to have_received(:require)
        .with('mutant/integration/null')
        .ordered

      expect(described_class)
        .to have_received(:const_get)
        .with('Null')
        .ordered

      expect(described_class::Null)
        .to have_received(:new)
        .with(object.to_h)
        .ordered

      expect(integration)
        .to have_received(:setup)
        .ordered
    end

    it 'returns integration instance' do
      expect(apply).to eql(
        Mutant::Either::Right.new(integration)
      )
    end
  end
end

RSpec.describe Mutant::Integration::Null do
  let(:object) do
    described_class.new(
      expression_parser: expression_parser,
      timer:             timer
    )
  end

  let(:expression_parser) { instance_double(Mutant::Expression::Parser) }
  let(:timer)             { instance_double(Mutant::Timer)              }

  describe '#all_tests' do
    subject { object.all_tests }

    it { should eql([]) }

    it_should_behave_like 'an idempotent method'
  end

  describe '#call' do
    let(:tests) { instance_double(Array) }

    subject { object.call(tests) }

    it 'returns test result' do
      should eql(
        Mutant::Result::Test.new(
          output:  '',
          passed:  true,
          runtime: 0.0,
          tests:   tests
        )
      )
    end
  end
end
