# frozen_string_literal: true

RSpec.describe Mutant::Transform::Hash::Slice do
  subject { described_class.new(keys:) }

  let(:keys) { %w[foo bar] }

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

      context 'with named and other keys' do
        let(:input) { { 'foo' => 1, 'baz' => 2, 'bar' => 3 } }

        it 'returns the named keys in input order' do
          expect(apply).to eql(Mutant::Either::Right.new('foo' => 1, 'bar' => 3))
        end
      end

      context 'with only other keys' do
        let(:input) { { 'baz' => 2 } }

        it 'returns an empty hash' do
          expect(apply).to eql(Mutant::Either::Right.new({}))
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
