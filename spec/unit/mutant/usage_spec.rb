# frozen_string_literal: true

RSpec.describe Mutant::Usage do
  let(:class_under_test) do
    Class.new(described_class) do
      const_set(:MESSAGE, 'the-message')
      const_set(:VALUE, 'the-value')
    end
  end

  let(:object) { class_under_test.new }

  describe '#merge' do
    let(:other) { Object.new }

    def apply
      object.merge(other)
    end

    it 'returns object' do
      expect(apply).to be(object)
    end
  end

  describe '#message' do
    def apply
      object.message
    end

    it 'returns expected message' do
      expect(apply).to eql('the-message')
    end
  end

  describe '#value' do
    def apply
      object.value
    end

    it 'returns success' do
      expect(apply).to eql('the-value')
    end
  end

  describe '#verify' do
    def apply
      object.verify
    end

    it 'returns success' do
      expect(apply).to eql(right(nil))
    end
  end

  describe '.parse' do
    def apply
      described_class.parse(value)
    end

    {
      'opensource' => described_class::Opensource.new,
      'commercial' => described_class::Commercial.new
    }.each do |value, usage|
      context "on #{value.inspect}" do
        let(:value) { value }

        it 'returns expected usage' do
          expect(apply).to eql(right(usage))
        end
      end
    end

    context 'on unknown value' do
      let(:value) { 'unknown' }

      it 'returns error' do
        expect(apply).to eql(left('Unknown usage option: "unknown"'))
      end
    end
  end
end

RSpec.describe Mutant::Usage::Unknown do
  let(:object) { described_class.new }

  describe '#verify' do
    def apply
      object.verify
    end

    it 'returns error' do
      expect(apply).to eql(left(described_class::MESSAGE))
    end
  end

  describe '#merge' do
    let(:other) { Object.new }

    def apply
      object.merge(other)
    end

    it 'returns other' do
      expect(apply).to be(other)
    end
  end
end
