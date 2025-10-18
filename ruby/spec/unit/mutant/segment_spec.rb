# frozen_string_literal: true

RSpec.describe Mutant::Segment do
  let(:recording_start) { 10 }

  subject do
    described_class.new(
      id:              SecureRandom.uuid,
      name:            :test_segment,
      parent_id:       nil,
      timestamp_end:   13,
      timestamp_start: 11
    )
  end

  describe '#elapsed' do
    it 'returns expected value' do
      expect(subject.elapsed).to eql(2)
    end
  end

  describe '#offset_end' do
    it 'returns expected value' do
      expect(subject.offset_end(recording_start)).to eql(3)
    end
  end

  describe '#offset_start' do
    it 'returns expected value' do
      expect(subject.offset_start(recording_start)).to eql(1)
    end
  end
end
