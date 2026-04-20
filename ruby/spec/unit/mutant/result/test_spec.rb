# frozen_string_literal: true

RSpec.describe Mutant::Result::Test::VoidValue do
  describe '.new' do
    it 'returns expected attributes' do
      expect(described_class.instance.to_h).to eql(
        job_index: nil,
        output:    '',
        passed:    false,
        runtime:   0.0
      )
    end
  end
end

RSpec.describe Mutant::Result::Test do
  describe 'JSON round trip' do
    it 'round trips with present job_index' do
      object = described_class.new(job_index: 1, output: 'ok', passed: true, runtime: 1.5)
      dumped = described_class::CODEC.dump(object).from_right
      loaded = described_class::CODEC.load(dumped).from_right

      expect(loaded).to eql(object)
    end

    it 'round trips with nil job_index' do
      object = described_class.new(job_index: nil, output: '', passed: false, runtime: 0.0)
      dumped = described_class::CODEC.dump(object).from_right
      loaded = described_class::CODEC.load(dumped).from_right

      expect(loaded).to eql(object)
    end
  end
end
