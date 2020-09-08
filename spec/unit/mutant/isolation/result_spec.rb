# frozen_string_literal: true

RSpec.describe Mutant::Isolation::Result do
  describe '#success?' do
    let(:value) { double('Object') }

    def apply
      effective_class.new(value).success?
    end

    context 'on success instance' do
      let(:effective_class) { described_class::Success }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end

    context 'on error instance' do
      let(:effective_class) { described_class::Exception }

      it 'returns false' do
        expect(apply).to be(false)
      end
    end
  end

  describe '#add_error' do
    let(:other)  { described_class::Success.new(object) }
    let(:value)  { double('Object')                     }
    let(:object) { described_class::Success.new(value)  }

    def apply
      object.add_error(other)
    end

    it 'returns chain instance' do
      expect(apply).to eql(described_class::ErrorChain.new(other, object))
    end
  end

  describe '#log' do
    let(:value) { double('Object') }

    def apply
      object.log
    end

    context 'on exception result' do
      let(:object) { described_class::Exception.new(value) }

      it 'returns the empty string' do
        expect(apply).to eql('')
      end
    end

    context 'on success result' do
      let(:object) { described_class::Success.new(value) }

      it 'returns the empty string' do
        expect(apply).to eql('')
      end
    end

    context 'on argument' do
      let(:object) { described_class::Success.new(value, 'foo') }

      it 'returns the empty string' do
        expect(apply).to eql('foo')
      end
    end
  end
end
