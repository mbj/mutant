# frozen_string_literal: true

RSpec.describe Mutant::Env do
  subject do
    described_class.new(
      config:           config,
      hooks:            hooks,
      integration:      integration,
      matchable_scopes: [],
      mutations:        [mutation],
      parser:           Mutant::Parser.new,
      selector:         selector,
      subjects:         subjects,
      world:            world
    )
  end

  let(:hooks)             { instance_double(Mutant::Hooks)       }
  let(:integration_class) { Mutant::Integration::Null            }
  let(:isolation)         { Mutant::Isolation::None.new          }
  let(:process_status)    { instance_double(Process::Status)     }
  let(:reporter)          { instance_double(Mutant::Reporter)    }
  let(:selector)          { instance_double(Mutant::Selector)    }
  let(:subject_a)         { instance_double(Mutant::Subject, :a) }
  let(:subject_b)         { instance_double(Mutant::Subject, :b) }
  let(:subjects)          { [subject_a, subject_b]               }
  let(:test_a)            { instance_double(Mutant::Test, :a)    }
  let(:test_b)            { instance_double(Mutant::Test, :b)    }
  let(:test_c)            { instance_double(Mutant::Test, :c)    }
  let(:world)             { fake_world                           }

  let(:integration) do
    instance_double(Mutant::Integration, all_tests: [test_a, test_b, test_c])
  end

  let(:mutation) do
    instance_double(
      Mutant::Mutation,
      subject: subject_a
    )
  end

  let(:mutation_config) do
    Mutant::Mutation::Config::DEFAULT.with(timeout: 1.0)
  end

  let(:config) do
    instance_double(
      Mutant::Config,
      expression_parser: instance_double(Mutant::Expression::Parser),
      integration:       integration_class,
      isolation:         isolation,
      mutation:          mutation_config,
      reporter:          reporter
    )
  end

  before do
    allow(selector).to receive(:call)
      .with(subject_a)
      .and_return([test_a, test_b])

    allow(selector).to receive(:call)
      .with(subject_b)
      .and_return([test_b, test_c])

    allow(world.timer).to receive(:now).and_return(2.0, 3.0)
  end

  def isolation_success(value)
    Mutant::Isolation::Result.new(
      log:            '',
      exception:      nil,
      process_status: process_status,
      timeout:        nil,
      value:          value
    )
  end

  describe '#cover_index' do
    let(:mutation_index) { 0 }

    def apply
      subject.cover_index(mutation_index)
    end

    before do
      allow(isolation).to receive(:call) do |&block|
        isolation_success(block.call)
      end

      allow(mutation).to receive_messages(insert: loader_result)

      allow(hooks).to receive_messages(run: undefined)
    end

    shared_examples 'mutation kill' do
      it 'returns expected result' do
        expect(apply).to eql(
          Mutant::Result::MutationIndex.new(
            isolation_result: isolation_result,
            mutation_index:   mutation_index,
            runtime:          1.0
          )
        )
      end
    end

    context 'when loader is successful' do
      let(:isolation_result) { isolation_success(test_result)        }
      let(:loader_result)    { Mutant::Either::Right.new(nil)        }
      let(:test_result)      { instance_double(Mutant::Result::Test) }

      before do
        allow(integration).to receive_messages(call: test_result)
      end

      it 'performs IO in expected sequence' do
        apply

        expect(isolation).to have_received(:call).ordered.with(config.mutation.timeout)
        expect(hooks).to have_received(:run).ordered.with(:mutation_insert_pre, mutation)
        expect(mutation).to have_received(:insert).ordered.with(world.kernel)
        expect(hooks).to have_received(:run).ordered.with(:mutation_insert_post, mutation)
        expect(integration).to have_received(:call).ordered.with([test_a, test_b])
      end

      include_examples 'mutation kill'
    end

    context 'when loader is not successful' do
      let(:loader_result) { Mutant::Either::Left.new(nil) }

      let(:isolation_result) do
        isolation_success(Mutant::Result::Test::VoidValue.instance)
      end

      it 'performs IO in expected sequence' do
        apply

        expect(isolation).to have_received(:call).ordered
        expect(mutation).to have_received(:insert).ordered.with(world.kernel)
      end

      include_examples 'mutation kill'
    end
  end

  describe '#selections' do
    def apply
      subject.selections
    end

    it 'returns expected selections' do
      expect(apply).to eql(
        subject_a => [test_a, test_b],
        subject_b => [test_b, test_c]
      )
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
      expect(apply).to be(1)
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

    context 'on empty subjects' do
      let(:subjects) { [] }

      it 'returns expected value' do
        expect(apply).to eql(Rational(0))
      end
    end

    context 'on non empty subjects' do
      it 'returns expected value' do
        expect(apply).to eql(Rational(3, 2))
      end
    end
  end

  describe '.empty' do
    def apply
      described_class.empty(world, config)
    end

    it 'returns empty env' do
      integration = Mutant::Integration::Null.new(
        expression_parser: config.expression_parser,
        world:             world
      )

      expect(apply).to eql(
        described_class.new(
          config:           config,
          hooks:            Mutant::Hooks.empty,
          integration:      integration,
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

  describe '#record' do
    before do
      allow(subject.world.recorder).to receive(:record) do |name, &block|
        events << [name, block.call]
      end
    end

    let(:block)  { -> { :value } }
    let(:events) { [] }

    def apply
      subject.record(:test_segment, &block)
    end

    it 'forwards calls to configured segment recorder' do
      apply

      expect(events).to eql([%i[test_segment value]])
    end
  end
end
