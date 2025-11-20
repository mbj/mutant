# frozen_string_literal: true

RSpec.describe Mutant::Mutation::Operators do
  let(:class_under_test) do
    Class.new(described_class) do
      const_set(:SELECTOR_REPLACEMENTS, test: %i[selector replacements])
      const_set(:NAME, :test)
    end
  end

  describe '#selector_replacements' do
    subject { class_under_test.new }

    def apply
      subject.selector_replacements
    end

    it 'returns expected value' do
      expect(apply).to eql(test: %i[selector replacements])
    end
  end

  describe '.operators_name' do
    def apply
      class_under_test.operators_name
    end

    it 'returns expected value' do
      expect(apply).to be(:test)
    end
  end

  describe '.parse' do
    def apply
      class_under_test.parse(name)
    end

    context 'full name' do
      let(:name) { 'full' }

      it 'returns expected value' do
        expect(apply).to eql(Mutant::Either::Right.new(described_class::Full.new))
      end
    end

    context 'light name' do
      let(:name) { 'light' }

      it 'returns expected value' do
        expect(apply).to eql(Mutant::Either::Right.new(described_class::Light.new))
      end
    end

    context 'unknown name' do
      let(:name) { 'other' }

      it 'returns expected value' do
        expect(apply).to eql(Mutant::Either::Left.new('Unknown operators: other'))
      end
    end
  end
end
