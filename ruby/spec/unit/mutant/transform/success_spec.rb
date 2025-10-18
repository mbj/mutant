# frozen_string_literal: true

RSpec.describe Mutant::Transform::Success do
  subject { described_class.new(block:) }

  let(:block) { ->(value) { value * 2 } }

  describe '#call' do
    def apply
      subject.call(input)
    end

    let(:input) { 3 }

    it 'returns success' do
      expect(apply).to eql(right(6))
    end
  end

  describe '#slug' do
    def apply
      subject.slug
    end

    it 'returns name' do
      expect(apply).to eql(described_class.name)
    end
  end
end
