# frozen_string_literal: true

RSpec.describe Mutant::Transform::Block do
  subject { described_class.new(name: name, block: block) }

  let(:block) { ->(value) { right(value * 2) } }
  let(:name)  { :external                      }

  describe '#call' do
    def apply
      subject.call(input)
    end

    let(:input) { 3 }

    context 'when block suceeds' do
      it 'returns success' do
        expect(apply).to eql(right(6))
      end
    end

    context 'when block fails' do
      let(:block) { ->(_value) { left('some error') } }

      it 'returns expected error' do
        expect(apply).to eql(
          left(
            Mutant::Transform::Error.new(
              cause:     nil,
              input:     input,
              message:   'some error',
              transform: subject
            )
          )
        )
      end
    end
  end

  describe '#slug' do
    def apply
      subject.slug
    end

    it 'returns name' do
      expect(apply).to be(name)
    end
  end

  describe '.capture' do
    def apply
      described_class.capture(name, &block)
    end

    it 'returns expected transform' do
      expect(apply).to eql(described_class.new(name: name, block: block))
    end
  end
end
