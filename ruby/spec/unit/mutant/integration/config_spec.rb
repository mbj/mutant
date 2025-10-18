# frozen_string_literal: true

RSpec.describe Mutant::Integration::Config do
  describe '#merge' do
    let(:original_name) { 'original-name' }
    let(:other_name)    { 'other-name' }

    subject do
      described_class.new(
        name:      original_name,
        arguments: %w[original-argument]
      )
    end

    def apply
      subject.merge(other)
    end

    let(:other) do
      described_class.new(
        name:      other_name,
        arguments: %w[other-argument]
      )
    end

    context 'when other name was present' do
      it 'uses other name' do
        expect(apply.name).to eql(other_name)
      end
    end

    context 'when other name was absent' do
      let(:other_name) { nil }
      it 'keeps original name' do
        expect(apply.name).to eql(original_name)
      end
    end

    it 'concatenates arguments' do
      expect(apply.arguments).to eql(%w[original-argument other-argument])
    end
  end
end
