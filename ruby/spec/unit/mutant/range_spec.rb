# frozen_string_literal: true

RSpec.describe Mutant::Range do
  describe '.overlap?' do
    def apply
      described_class.overlap?(left, right)
    end

    context 'no overlap left before right' do
      # |---|
      #       |---|
      let(:left)  { 1..2 }
      let(:right) { 3..4 }

      it 'returns false' do
        expect(apply).to be(false)
      end
    end

    context 'no overlap right before left' do
      #       |---|
      # |---|
      let(:left)  { 3..4 }
      let(:right) { 1..2 }

      it 'returns false' do
        expect(apply).to be(false)
      end
    end

    context 'left includes right' do
      # |----------------|
      #       |---|
      let(:left)  { 1..4 }
      let(:right) { 2..3 }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end

    context 'right includes left' do
      #       |---|
      # |----------------|
      let(:left)  { 2..3 }
      let(:right) { 1..4 }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end

    context 'right starts with left end' do
      # |----|
      #      |----|
      let(:left)  { 1..2 }
      let(:right) { 2..3 }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end

    context 'left starts with right end' do
      #      |----|
      # |----|
      let(:left)  { 2..3 }
      let(:right) { 1..2 }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end

    context 'left starts with right start' do
      # |----|
      # |---------|
      let(:left)  { 1..2 }
      let(:right) { 1..3 }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end

    context 'left starts with right start' do
      # |---------|
      # |----|
      let(:left)  { 1..3 }
      let(:right) { 1..2 }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end

    context 'left ends with right end' do
      #      |----|
      # |---------|
      let(:left)  { 2..3 }
      let(:right) { 1..3 }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end

    context 'right ends with left end' do
      # |---------|
      #      |----|
      let(:left)  { 1..3 }
      let(:right) { 2..3 }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end

    context 'left end intersects with right' do
      # |---------|
      #      |----------|
      let(:left)  { 1..3 }
      let(:right) { 2..4 }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end

    context 'right end intersects with left' do
      #      |----------|
      # |---------|
      let(:left)  { 2..4 }
      let(:right) { 1..2 }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end
  end
end
