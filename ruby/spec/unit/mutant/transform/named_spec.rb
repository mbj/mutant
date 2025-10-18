# frozen_string_literal: true

RSpec.describe Mutant::Transform::Named do
  subject { described_class.new(name:, transform:) }

  let(:name)      { 'transform-name'               }
  let(:transform) { Mutant::Transform::Boolean.new }

  describe '#slug' do
    def apply
      subject.slug
    end

    it 'returns name' do
      expect(apply).to be(name)
    end
  end

  describe '#call' do
    def apply
      subject.call(input)
    end

    context 'on valid input' do
      let(:input) { true }

      it 'returns sucess' do
        expect(apply).to eql(Mutant::Either::Right.new(input))
      end
    end

    context 'on invalid input' do
      let(:input) { 1 }

      let(:error) do
        Mutant::Transform::Error.new(
          cause:     transform.call(input).from_left,
          input:,
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
