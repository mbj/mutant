# frozen_string_literal: true

RSpec.describe Mutant::Result::Test::VoidValue do
  describe '.new' do
    it 'returns expected attributes' do
      expect(described_class.instance.to_h).to eql(
        job_index: nil,
        output:    Mutant::LogCapture::String.new(content: ''),
        passed:    false,
        runtime:   0.0
      )
    end
  end
end

RSpec.describe Mutant::Result::Test do
  describe 'JSON round trip' do
    it 'round trips with present job_index' do
      object = described_class.new(
        job_index: 1,
        output:    Mutant::LogCapture::String.new(content: 'ok'),
        passed:    true,
        runtime:   1.5
      )
      dumped = described_class::CODEC.dump(object).from_right
      loaded = described_class::CODEC.load(dumped).from_right

      expect(loaded).to eql(object)
    end

    it 'round trips with nil job_index' do
      object = described_class.new(
        job_index: nil,
        output:    Mutant::LogCapture::String.new(content: ''),
        passed:    false,
        runtime:   0.0
      )
      dumped = described_class::CODEC.dump(object).from_right
      loaded = described_class::CODEC.load(dumped).from_right

      expect(loaded).to eql(object)
    end

    it 'round trips with binary output' do
      object = described_class.new(
        job_index: nil,
        output:    Mutant::LogCapture::Binary.new(content: "\xFF\xFE".b),
        passed:    false,
        runtime:   0.0
      )
      dumped = described_class::CODEC.dump(object).from_right
      loaded = described_class::CODEC.load(dumped).from_right

      expect(loaded).to eql(object)
    end
  end
end
