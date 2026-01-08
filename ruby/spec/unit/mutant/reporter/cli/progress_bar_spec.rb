# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::ProgressBar do
  describe '.build' do
    subject { described_class.build(current:, total:) }

    let(:current) { 5 }
    let(:total)   { 10 }

    it 'creates a progress bar with default settings' do
      expect(subject).to be_a(described_class)
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

      it { should eql(0.0) }
    end

    context 'when progress is 50%' do
      let(:current) { 50 }
      let(:total)   { 100 }

      it { should eql(50.0) }
    end

    context 'when progress is 100%' do
      let(:current) { 100 }
      let(:total)   { 100 }

      it { should eql(100.0) }
    end

    context 'when total is 0' do
      let(:current) { 0 }
      let(:total)   { 0 }

      it { should eql(0.0) }
    end
  end
end
