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
      let(:effective_class) { described_class::Error }

      it 'returns true' do
        expect(apply).to be(false)
      end
    end
  end
end
