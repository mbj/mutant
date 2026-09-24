# frozen_string_literal: true

RSpec.describe Mutant::Transform::Hash::Map do
  subject { described_class.new(key:, value:) }

  let(:key)   { Mutant::Transform::STRING       }
  let(:value) { Mutant::Transform::Boolean.new  }

  describe '#call' do
    def apply
      subject.call(input)
    end

    context 'on hash input' do
      context 'empty' do
        let(:input) { {} }

        it 'returns success' do
          expect(apply).to eql(Mutant::Either::Right.new({}))
        end
      end

      context 'valid pairs' do
        let(:input) { { 'foo' => true, 'bar' => false } }

        it 'returns success' do
          expect(apply).to eql(Mutant::Either::Right.new(input))
        end
      end

      context 'transformed pairs' do
        let(:input) { { 'foo' => { 'bar' => 1 } } }

        let(:key)   { Mutant::Transform::Success.new(block: :to_sym.to_proc) }
        let(:value) { Mutant::Transform::Hash::Symbolize.new                 }

        it 'returns transformed pairs' do
          expect(apply).to eql(Mutant::Either::Right.new(foo: { bar: 1 }))
        end
      end

      context 'invalid key' do
        let(:input) { { 'foo' => true, 1 => false } }

        let(:string_error) do
          Mutant::Transform::Error.new(
            cause:     nil,
            input:     1,
            message:   'Expected: String but got: Integer',
            transform: key
          )
        end

        let(:key_error) do
          Mutant::Transform::Error.new(
            cause:     string_error,
            input:     1,
            message:   nil,
            transform: Mutant::Transform::Hash::Key.new(value: 1, transform: key)
          )
        end

        let(:error) do
          Mutant::Transform::Error.new(
            cause:     key_error,
            input:,
            message:   nil,
            transform: subject
          )
        end

        it 'returns failure' do
          expect(apply).to eql(Mutant::Either::Left.new(error))
        end
      end

      context 'invalid value' do
        let(:input) { { 'foo' => true, 'bar' => 1 } }

        let(:boolean_error) do
          Mutant::Transform::Error.new(
            cause:     nil,
            input:     1,
            message:   'Expected: boolean but got: 1',
            transform: value
          )
        end

        let(:key_error) do
          Mutant::Transform::Error.new(
            cause:     boolean_error,
            input:     1,
            message:   nil,
            transform: Mutant::Transform::Hash::Key.new(value: 'bar', transform: value)
          )
        end

        let(:error) do
          Mutant::Transform::Error.new(
            cause:     key_error,
            input:,
            message:   nil,
            transform: subject
          )
        end

        it 'returns failure' do
          expect(apply).to eql(Mutant::Either::Left.new(error))
        end
      end

      context 'keys mapped onto one' do
        let(:input) { { 'foo' => true, 'FOO' => false } }

        let(:key) { Mutant::Transform::Success.new(block: :downcase.to_proc) }

        let(:error) do
          Mutant::Transform::Error.new(
            cause:     nil,
            input:,
            message:   'Key transform maps distinct keys onto one',
            transform: subject
          )
        end

        it 'returns failure' do
          expect(apply).to eql(Mutant::Either::Left.new(error))
        end
      end
    end

    context 'on other input' do
      let(:input) { false }

      let(:error) do
        Mutant::Transform::Error.new(
          cause:     nil,
          input:,
          message:   'Expected: Hash but got: FalseClass',
          transform: subject
        )
      end

      it 'returns failure' do
        expect(apply).to eql(Mutant::Either::Left.new(error))
      end
    end
  end
end
