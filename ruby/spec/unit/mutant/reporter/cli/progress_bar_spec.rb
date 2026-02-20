# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::ProgressBar do
  describe '.build' do
    subject { described_class.build(current:, total:) }

    let(:current) { 5 }
    let(:total)   { 10 }

    it 'creates a progress bar with default settings' do
      expect(subject).to be_a(described_class)
    end

    it 'sets current from parameter' do
      expect(subject.current).to eql(current)
    end

    it 'sets total from parameter' do
      expect(subject.total).to eql(total)
    end

    it 'uses DEFAULT_WIDTH for width' do
      expect(subject.width).to eql(described_class::DEFAULT_WIDTH)
    end

    it 'uses FILLED_CHAR for filled_char' do
      expect(subject.filled_char).to eql(described_class::FILLED_CHAR)
    end

    it 'uses EMPTY_CHAR for empty_char' do
      expect(subject.empty_char).to eql(described_class::EMPTY_CHAR)
    end

    context 'with custom width' do
      subject { described_class.build(current:, total:, width: 20) }

      it 'uses provided width' do
        expect(subject.width).to eql(20)
      end
    end
  end

  describe '#render' do
    subject { progress_bar.render }

    let(:progress_bar) { described_class.build(current:, total:, width:) }
    let(:width)        { 10 }

    context 'when progress is 0%' do
      let(:current) { 0 }
      let(:total)   { 100 }

      it 'renders empty bar' do
        expect(subject).to eql('░░░░░░░░░░')
      end
    end

    context 'when progress is 50%' do
      let(:current) { 50 }
      let(:total)   { 100 }

      it 'renders half-filled bar' do
        expect(subject).to eql('█████░░░░░')
      end
    end

    context 'when rounding affects filled_width' do
      # 46/100 * 10 = 4.6, rounds to 5
      let(:current) { 46 }
      let(:total)   { 100 }

      it 'rounds filled width correctly' do
        expect(subject).to eql('█████░░░░░')
      end
    end

    context 'when rounding down affects filled_width' do
      # 44/100 * 10 = 4.4, rounds to 4
      let(:current) { 44 }
      let(:total)   { 100 }

      it 'rounds filled width correctly' do
        expect(subject).to eql('████░░░░░░')
      end
    end

    context 'when progress is 100%' do
      let(:current) { 100 }
      let(:total)   { 100 }

      it 'renders fully filled bar' do
        expect(subject).to eql('██████████')
      end
    end

    context 'when total is 0' do
      let(:current) { 0 }
      let(:total)   { 0 }

      it 'renders empty bar' do
        expect(subject).to eql('░░░░░░░░░░')
      end
    end

    context 'when progress exceeds total' do
      let(:current) { 150 }
      let(:total)   { 100 }

      it 'renders fully filled bar' do
        expect(subject).to eql('██████████')
      end
    end
  end

  describe '#percentage' do
    subject { progress_bar.percentage }

    let(:progress_bar) { described_class.build(current:, total:) }

    context 'when progress is 0%' do
      let(:current) { 0 }
      let(:total)   { 100 }

      it { is_expected.to eql(0.0) }
    end

    context 'when progress is 50%' do
      let(:current) { 50 }
      let(:total)   { 100 }

      it { is_expected.to eql(50.0) }
    end

    context 'when progress is 100%' do
      let(:current) { 100 }
      let(:total)   { 100 }

      it { is_expected.to eql(100.0) }
    end

    context 'when total is 0' do
      let(:current) { 0 }
      let(:total)   { 0 }

      it { is_expected.to eql(0.0) }
    end
  end
end
