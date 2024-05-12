# frozen_string_literal: true

RSpec.describe Mutant::Util, '.one' do
  let(:item) { instance_double(Object) }

  def apply
    described_class.one(array)
  end

  context 'when array has exactly one element' do
    context 'and that element is nil' do
      let(:array) { [nil] }

      it 'returns nil' do
        expect(apply).to be(nil)
      end
    end

    context 'and that element is false' do
      let(:array) { [false] }

      it 'returns false' do
        expect(apply).to be(false)
      end
    end

    context 'and that element is a regular object' do
      let(:array) { [item] }

      it 'returns first element' do
        expect(apply).to be(item)
      end
    end
  end

  context 'when array is empty' do
    let(:array) { [] }

    it 'raises expected error' do
      expect { apply }
        .to raise_error(described_class::SizeError)
        .with_message('expected size to be exactly 1 but size was 0')
    end
  end

  context 'when array has more than one element' do
    let(:array) { [1, 2] }

    it 'raises expected error' do
      expect { apply }
        .to raise_error(described_class::SizeError)
        .with_message('expected size to be exactly 1 but size was 2')
    end
  end
end
