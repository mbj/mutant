# frozen_string_literal: true

module VariableSpec
  module VariableHelper
    def empty
      described_class.new(
        condition_variable: condition_variable_class,
        mutex:              mutex_class
      )
    end

    def full(value)
      described_class.new(
        condition_variable: condition_variable_class,
        mutex:              mutex_class,
        value:
      )
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def self.shared_setup
      lambda do |_host|
        let(:condition_variable_class) { class_double(ConditionVariable)            }
        let(:expected_result)          { value                                      }
        let(:full_condition)           { instance_double(ConditionVariable, 'full') }
        let(:mutex)                    { instance_double(Mutex)                     }
        let(:mutex_class)              { class_double(Mutex)                        }
        let(:value)                    { instance_double(Object, 'value')           }

        let(:synchronize) do
          {
            receiver: mutex,
            selector: :synchronize,
            reaction: { yields: [] }
          }
        end

        let(:signal_full) do
          {
            receiver: full_condition,
            selector: :signal
          }
        end

        let(:put) do
          {
            receiver:  full_condition,
            selector:  :wait,
            arguments: [mutex],
            reaction:  { execute: -> { subject.put(value) } }
          }
        end

        let(:wait_empty) do
          {
            receiver:  empty_condition,
            selector:  :wait,
            arguments: [mutex]
          }
        end

        let(:wait_full) do
          {
            receiver:  full_condition,
            selector:  :wait,
            arguments: [mutex]
          }
        end

        let(:signal_empty) do
          {
            receiver: empty_condition,
            selector: :signal
          }
        end

        shared_examples 'consumes events' do
          specify do
            verify_events do
              expect(apply).to eql(expected_result)
            end
          end
        end
      end
    end
  end
end

RSpec.describe Mutant::Variable::IVar do
  include VariableSpec::VariableHelper

  class_eval(&VariableSpec::VariableHelper.shared_setup)

  subject { empty }

  let(:setup) do
    [
      {
        receiver: condition_variable_class,
        selector: :new,
        reaction: { return: full_condition }
      },
      {
        receiver: mutex_class,
        selector: :new,
        reaction: { return: mutex }
      }
    ]
  end

  describe '#take' do
    def apply
      subject.take
    end

    context 'when is initially full' do
      subject { full(value) }

      let(:raw_expectations) { [*setup, synchronize] }

      include_examples 'consumes events'
    end

    context 'when is initially empty' do
      let(:raw_expectations) do
        [
          *setup,
          synchronize,
          put,
          synchronize,
          signal_full
        ]
      end

      include_examples 'consumes events'
    end
  end

  describe '#take_timeout' do
    def apply
      subject.take_timeout(1.0)
    end

    context 'when is initially full' do
      subject { full(value) }

      let(:raw_expectations) { [*setup, synchronize] }

      let(:expected_result) do
        Mutant::Variable.const_get(:Result)::Value.new(value)
      end

      include_examples 'consumes events'
    end

    context 'when is initially empty' do
      def wait(time)
        {
          receiver:  full_condition,
          selector:  :wait,
          arguments: [mutex, time]
        }
      end

      def elapsed(time)
        {
          receiver: Mutant::Variable::Timer,
          selector: :elapsed,
          reaction: { yields: [], return: time }
        }
      end

      context 'and timeout occurs before value is put' do
        let(:expected_result) do
          Mutant::Variable.const_get(:Result)::Timeout.new
        end

        context 'wait exactly runs to zero left time on the clock' do
          let(:raw_expectations) do
            [
              *setup,
              synchronize,
              elapsed(0.5),
              wait(1.0),
              elapsed(0.5),
              wait(0.5)
            ]
          end

          include_examples 'consumes events'
        end

        context 'wait overruns timeout' do
          let(:raw_expectations) do
            [
              *setup,
              synchronize,
              elapsed(1.5),
              wait(1.0)
            ]
          end

          include_examples 'consumes events'
        end
      end

      context 'and put occurs before timeout' do
        let(:expected_result) do
          Mutant::Variable.const_get(:Result)::Value.new(value)
        end

        let(:raw_expectations) do
          [
            *setup,
            synchronize,
            elapsed(0.5),
            wait(1.0).merge(reaction: { execute: -> { subject.put(value) } }),
            synchronize,
            signal_full
          ]
        end

        include_examples 'consumes events'
      end
    end
  end

  describe '#put' do
    def apply
      subject.put(value)
    end

    context 'when is initially empty' do
      context 'when not reading result' do
        let(:expected_result) { subject }

        let(:raw_expectations) do
          [
            *setup,
            synchronize,
            signal_full
          ]
        end

        include_examples 'consumes events'
      end

      context 'when reading result back' do
        let(:expected_result) { value }

        def apply
          super
          subject.read
        end

        let(:raw_expectations) do
          [
            *setup,
            synchronize,
            signal_full,
            synchronize
          ]
        end

        include_examples 'consumes events'
      end
    end

    context 'when is initially full' do
      subject { full(value) }

      let(:raw_expectations) { [*setup, synchronize] }

      it 'raises expected exception' do
        verify_events do
          expect { apply }.to raise_error(Mutant::Variable::IVar::Error, 'is immutable')
        end
      end
    end
  end

  describe '#try_put' do
    def apply
      subject.try_put(value)
    end

    let(:expected_result) { subject }

    context 'when is initially empty' do
      let(:raw_expectations) do
        [
          *setup,
          synchronize,
          signal_full
        ]
      end

      include_examples 'consumes events'

      context 'reading the put value' do
        let(:expected_result) { value }

        let(:raw_expectations) do
          [
            *super(),
            synchronize
          ]
        end

        def apply
          super
          subject.read
        end

        include_examples 'consumes events'
      end
    end

    context 'when is initially full' do
      subject { full(value) }

      let(:raw_expectations) { [*setup, synchronize] }

      include_examples 'consumes events'
    end
  end

  describe '#read' do
    def apply
      subject.read
    end

    context 'when is initially empty' do
      let(:raw_expectations) do
        [
          *setup,
          synchronize,
          wait_full.merge(reaction: { execute: -> { subject.put(value) } }),
          synchronize,
          signal_full
        ]
      end

      include_examples 'consumes events'
    end

    context 'when is initially full' do
      subject { full(value) }

      let(:raw_expectations) { [*setup, synchronize] }

      include_examples 'consumes events'
    end
  end

  describe '#with' do
    def apply
      subject.with do |value|
        @value = value
      end
    end

    before { @value = nil }

    context 'when is initially full' do
      subject { full(value) }

      let(:raw_expectations) { [*setup, synchronize] }

      include_examples 'consumes events'

      it 'should yield value' do
        verify_events do
          expect { apply }.to change { @value }.from(nil).to(value)
        end
      end
    end

    context 'when is initially empty' do
      subject { empty }

      let(:raw_expectations) do
        [
          *setup,
          synchronize,
          put,
          synchronize,
          signal_full
        ]
      end

      include_examples 'consumes events'

      it 'should yield value' do
        verify_events do
          expect { apply }.to change { @value }.from(nil).to(value)
        end
      end
    end
  end
  describe '#populate_with' do
    def apply
      subject.populate_with { @counter += 1 }
    end

    before do
      @counter = 0
    end

    context 'when is initially full' do
      subject { full(value) }

      let(:raw_expectations) { setup }

      include_examples 'consumes events'

      it 'does not not execute block' do
        verify_events do
          expect { apply }.to_not change { @counter }.from(0)
        end
      end
    end

    context 'when is initially empty' do
      subject { empty }

      context 'without contention' do
        let(:expected_result) { 1 }

        let(:raw_expectations) do
          [
            *setup,
            synchronize,
            signal_full
          ]
        end

        include_examples 'consumes events'

        it 'does execute block' do
          verify_events do
            expect { apply }.to change { @counter }.from(0).to(1)
          end
        end
      end

      context 'with contention' do
        let(:raw_expectations) do
          [
            *setup,
            synchronize.merge(pre_action: -> { subject.put(value) }),
            synchronize,
            signal_full
          ]
        end

        include_examples 'consumes events'

        it 'does not execute block' do
          verify_events do
            expect { apply }.to_not change { @counter }.from(0)
          end
        end
      end
    end
  end
end

RSpec.describe Mutant::Variable::MVar do
  include VariableSpec::VariableHelper

  class_eval(&VariableSpec::VariableHelper.shared_setup)

  subject { empty }

  let(:empty_condition) { instance_double(ConditionVariable, 'empty') }

  let(:setup) do
    [
      {
        receiver: condition_variable_class,
        selector: :new,
        reaction: { return: full_condition }
      },
      {
        receiver: mutex_class,
        selector: :new,
        reaction: { return: mutex }
      },
      {
        receiver: condition_variable_class,
        selector: :new,
        reaction: { return: empty_condition }
      },
      synchronize
    ]
  end

  describe '#put' do
    def apply
      subject.put(value)
    end

    context 'when is initially empty' do
      context 'when not reading result' do
        let(:expected_result) { subject }

        let(:raw_expectations) do
          [
            *setup,
            signal_full
          ]
        end

        include_examples 'consumes events'
      end

      context 'when reading result back' do
        let(:expected_result) { value }

        def apply
          super
          subject.read
        end

        let(:raw_expectations) do
          [
            *setup,
            signal_full,
            synchronize
          ]
        end

        include_examples 'consumes events'
      end
    end

    context 'when is initially full' do
      context 'when not reading result' do
        subject { full(value) }

        let(:expected_result) { subject }

        let(:raw_expectations) do
          [
            *setup,
            wait_empty.merge(reaction: { execute: -> { subject.take } }),
            synchronize,
            signal_empty,
            signal_full
          ]
        end

        include_examples 'consumes events'
      end

      context 'when reading result back' do
        subject { full(value) }

        def apply
          super
          subject.read
        end

        let(:expected_result) { value }

        let(:raw_expectations) do
          [
            *setup,
            wait_empty.merge(reaction: { execute: -> { subject.take } }),
            synchronize,
            signal_empty,
            signal_full,
            synchronize
          ]
        end

        include_examples 'consumes events'
      end
    end
  end

  describe '#modify' do
    let(:expected_result) { 1 }
    let(:value)           { 0 }

    def apply
      subject.modify(&:succ)
    end

    context 'when is initially empty' do
      let(:raw_expectations) do
        [
          *setup,
          wait_full.merge(reaction: { execute: -> { subject.put(value) } }),
          synchronize,
          signal_full,
          signal_full
        ]
      end

      include_examples 'consumes events'
    end

    context 'when is initially full' do
      subject { full(value) }

      let(:raw_expectations) do
        [
          *setup,
          signal_full
        ]
      end

      include_examples 'consumes events'
    end
  end

  describe '#take' do
    def apply
      subject.take
    end

    context 'when is initially empty' do
      let(:expected_result) { value }

      let(:raw_expectations) do
        [
          *setup,
          wait_full.merge(reaction: { execute: -> { subject.put(value) } }),
          synchronize,
          signal_full,
          signal_empty
        ]
      end

      include_examples 'consumes events'
    end

    context 'when is initially full' do
      subject { full(value) }

      let(:expected_result) { value }

      let(:raw_expectations) do
        [
          *setup,
          signal_empty
        ]
      end

      include_examples 'consumes events'
    end
  end
end

RSpec.describe Mutant::Variable.const_get(:Result)::Value do
  subject { described_class.new(object) }

  let(:object) { Object.new }

  describe '#frozen?' do
    def apply
      subject.frozen?
    end

    it 'returns true' do
      expect(apply).to be(true)
    end
  end

  describe '#timeout?' do
    def apply
      subject.timeout?
    end

    it 'returns false' do
      expect(apply).to be(false)
    end
  end

  describe '#value' do
    def apply
      subject.value
    end

    it 'returns value' do
      expect(apply).to be(object)
    end
  end
end

RSpec.describe Mutant::Variable.const_get(:Result)::Timeout do
  describe '.new' do
    it 'is instance of timeout' do
      expect(described_class.new.instance_of?(described_class)).to be(true)
    end

    it 'is idempotent' do
      expect(described_class.new).to be(described_class.new)
    end
  end

  describe '#frozen?' do
    def apply
      subject.frozen?
    end

    it 'returns true' do
      expect(apply).to be(true)
    end
  end

  describe '#timeout?' do
    def apply
      subject.timeout?
    end

    it 'returns true' do
      expect(apply).to be(true)
    end
  end

  describe '#value' do
    def apply
      subject.value
    end

    it 'returns nil' do
      expect(apply).to be(nil)
    end
  end
end

RSpec.describe Mutant::Variable::Timer do
  describe '.elapsed' do
    let(:raw_expectations) do
      [
        {
          receiver:  Process,
          selector:  :clock_gettime,
          arguments: [Process::CLOCK_MONOTONIC],
          reaction:  { return: 1 }
        },
        {
          receiver:  object,
          selector:  :to_s,
          arguments: [],
          reaction:  { return: '' }
        },
        {
          receiver:  Process,
          selector:  :clock_gettime,
          arguments: [Process::CLOCK_MONOTONIC],
          reaction:  { return: 3 }
        }
      ]
    end

    let(:object) { Object.new }
    let(:block)  { -> { object.to_s } }

    def apply
      described_class.elapsed(&block)
    end

    it 'returns elapsed time' do
      verify_events do
        expect(apply).to eql(2)
      end
    end
  end
end
