# frozen_string_literal: true

RSpec.describe Mutant::Result::Session do
  let(:object) do
    described_class.new(
      killtime:        0.0,
      mutant_version:  '0.15.1',
      pid:             12_345,
      ruby_version:    '4.0.1',
      runtime:         0.0,
      session_id:,
      subject_results: []
    )
  end

  describe '#timestamp' do
    # UUIDv7: first 48 bits encode milliseconds since epoch
    # 019cf6f1-77e8-... => hex 019cf6f177e8 => 1773897025512 ms
    let(:session_id) { '019cf6f1-77e8-74b6-82db-f8b5faf570cd' }

    it 'returns UTC time extracted from UUIDv7' do
      expect(object.timestamp).to be_a(Time)
    end

    it 'returns time in UTC' do
      expect(object.timestamp.utc?).to be(true)
    end

    it 'extracts correct millisecond timestamp' do
      expected_ms = 0x019cf6f177e8
      expected_time = Time.at(expected_ms / 1000.0).utc

      expect(object.timestamp).to eql(expected_time)
    end

    it 'does not include version nibble in timestamp' do
      # Position 13 is the version nibble (7 for UUIDv7)
      # If we accidentally include it, the timestamp would be wrong
      wrong_ms = 0x019cf6f177e87
      wrong_time = Time.at(wrong_ms / 1000.0).utc

      expect(object.timestamp).not_to eql(wrong_time)
    end

    it 'returns a plausible recent time' do
      expect(object.timestamp.year).to be >= 2025
    end
  end
end
