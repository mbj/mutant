# frozen_string_literal: true

RSpec.describe Mutant::Transform::Hash do
  subject { described_class.new(attributes) }

  let(:required) { []                                                  }
  let(:optional) { []                                                  }
  let(:symbol)   { Mutant::Transform::Primitive.new(primitive: Symbol) }

  let(:attributes) do
    {
      required:,
      optional:
    }
  end

  describe '#call' do
    def apply
      subject.call(input)
    end

    context 'on Hash input' do
      context 'empty' do
        let(:input) { {} }

        it 'returns sucess' do
          expect(apply).to eql(Mutant::Either::Right.new(input))
        end
      end

      context 'missing key' do
        let(:input)    { {}                                                         }
        let(:required) { [described_class::Key.new(value: :foo, transform: symbol)] }

        let(:error) do
          Mutant::Transform::Error.new(
            cause:     nil,
            input:,
            message:   'Missing keys: [:foo], Unexpected keys: []',
            transform: subject
          )
        end

        it 'returns error' do
          expect(apply).to eql(Mutant::Either::Left.new(error))
        end
      end

      context 'extra key' do
        let(:input) { { foo: :bar } }

        let(:error) do
          Mutant::Transform::Error.new(
            cause:     nil,
            input:,
            message:   'Missing keys: [], Unexpected keys: [:foo]',
            transform: subject
          )
        end

        it 'returns error' do
          expect(apply).to eql(Mutant::Either::Left.new(error))
        end
      end

      context 'using required' do
        let(:input)    { { foo: :bar }                                              }
        let(:required) { [described_class::Key.new(value: :foo, transform: symbol)] }

        it 'returns success' do
          expect(apply).to eql(Mutant::Either::Right.new(input))
        end
      end

      context 'using optional' do
        let(:optional) { [described_class::Key.new(value: :foo, transform: symbol)] }

        context 'not providing the optional key' do
          let(:input) { {} }

          it 'returns success' do
            expect(apply).to eql(Mutant::Either::Right.new(input))
          end
        end

        context 'providing the optional key' do
          let(:input) { { foo: :bar } }

          it 'returns success' do
            expect(apply).to eql(Mutant::Either::Right.new(input))
          end
        end
      end

      shared_examples 'key transform error' do
        let(:innermost_error) do
          Mutant::Transform::Error.new(
            cause:     nil,
            input:     'bar',
            message:   'Expected: Symbol but got: String',
            transform: symbol
          )
        end

        let(:inner_error) do
          Mutant::Transform::Error.new(
            cause:     innermost_error,
            input:     'bar',
            message:   nil,
            transform: key_transform
          )
        end

        let(:error) do
          Mutant::Transform::Error.new(
            cause:     inner_error,
            input:,
            message:   nil,
            transform: subject
          )
        end

        it 'returns failure' do
          expect(apply).to eql(Mutant::Either::Left.new(error))
        end
      end

      context 'key transform error' do
        let(:input) { { foo: 'bar' } }

        let(:key_transform) { described_class::Key.new(value: :foo, transform: symbol) }

        context 'on optional key' do
          let(:optional) { [key_transform] }

          include_examples 'key transform error'
        end

        context 'on required key' do
          let(:required) { [key_transform] }

          include_examples 'key transform error'
        end
      end
    end

    context 'on other input' do
      let(:input) { [] }

      let(:error) do
        Mutant::Transform::Error.new(
          cause:     nil,
          input:,
          message:   'Expected: Hash but got: Array',
          transform: subject
        )
      end

      it 'returns failure' do
        expect(apply).to eql(Mutant::Either::Left.new(error))
      end
    end
  end
end

RSpec.describe Mutant::Transform::Hash::Symbolize do
  subject { described_class.new }

  describe '#call' do
    def apply
      subject.call(input)
    end

    let(:input) { { 'foo' => 'bar' } }

    it 'returns success' do
      expect(apply).to eql(Mutant::Either::Right.new(foo: 'bar'))
    end
  end
end

RSpec.describe Mutant::Transform::Hash::Key do
  subject { described_class.new(value: :foo, transform: boolean) }

  let(:boolean) { Mutant::Transform::Boolean.new }

  describe '#slug' do
    def apply
      subject.slug
    end

    it 'returns expected slug' do
      expect(apply).to eql('[:foo]')
    end
  end

  describe '#call' do
    def apply
      subject.call(input)
    end

    context 'on valid input' do
      let(:input) { true }

      it 'returns success' do
        expect(apply).to eql(Mutant::Either::Right.new(true))
      end
    end

    context 'on invalid input' do
      let(:input) { 1 }

      let(:inner_error) do
        Mutant::Transform::Error.new(
          cause:     nil,
          input:     1,
          message:   'Expected: boolean but got: 1',
          transform: boolean
        )
      end

      let(:error) do
        Mutant::Transform::Error.new(
          cause:     inner_error,
          input:     1,
          message:   nil,
          transform: subject
        )
      end

      it 'returns failure' do
        expect(apply).to eql(Mutant::Either::Left.new(error))
      end
    end
  end
end
