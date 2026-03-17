# frozen_string_literal: true

RSpec.describe Mutant::Transform::Nullable do
  subject { described_class.new(transform: inner) }

  let(:inner) { Mutant::Transform::Primitive.new(primitive: String) }

  describe '#call' do
    def apply
      subject.call(input)
    end

    context 'on nil input' do
      let(:input) { nil }

      it 'returns success with nil' do
        expect(apply).to eql(right(nil))
      end
    end

    context 'on valid non-nil input' do
      let(:input) { 'hello' }

      it 'returns success from inner transform' do
        expect(apply).to eql(right('hello'))
      end
    end

    context 'on invalid non-nil input' do
      let(:input) { 1 }

      it 'returns failure from inner transform' do
        expect(apply).to eql(left(inner.call(1).from_left))
      end
    end
  end

  describe '#slug' do
    def apply
      subject.slug
    end

    it 'returns nullable-wrapped slug' do
      expect(apply).to eql('nullable(String)')
    end
  end
end
