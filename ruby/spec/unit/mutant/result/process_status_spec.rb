# frozen_string_literal: true

RSpec.describe Mutant::Result::ProcessStatus do
  describe '.from_process_status' do
    def apply
      described_class.from_process_status(process_status)
    end

    context 'with successful process status' do
      let(:process_status) do
        instance_double(Process::Status, exitstatus: 0)
      end

      it 'returns a ProcessStatus with exitstatus' do
        expect(apply.exitstatus).to be(0)
      end
    end

    context 'with failed process status' do
      let(:process_status) do
        instance_double(Process::Status, exitstatus: 1)
      end

      it 'returns a ProcessStatus with exitstatus' do
        expect(apply.exitstatus).to be(1)
      end
    end
  end

  describe '#success?' do
    context 'when exitstatus is 0' do
      it 'returns true' do
        expect(described_class.new(exitstatus: 0).success?).to be(true)
      end
    end

    context 'when exitstatus is non-zero' do
      it 'returns false' do
        expect(described_class.new(exitstatus: 1).success?).to be(false)
      end
    end
  end

  describe '#inspect' do
    it 'returns stable representation without memory address' do
      expect(described_class.new(exitstatus: 0).inspect)
        .to eql('#<Mutant::Result::ProcessStatus exitstatus=0>')
    end

    it 'includes exitstatus value' do
      expect(described_class.new(exitstatus: 1).inspect)
        .to eql('#<Mutant::Result::ProcessStatus exitstatus=1>')
    end

    it 'uses class name not class itself' do
      expect(Class.new(described_class).new(exitstatus: 0).inspect)
        .to eql('#< exitstatus=0>')
    end
  end

  describe 'JSON round trip' do
    it 'round trips with zero exitstatus' do
      object = described_class.new(exitstatus: 0)
      dumped = described_class::JSON.dump(object).from_right
      loaded = described_class::JSON.load(dumped).from_right

      expect(loaded).to eql(object)
    end

    it 'round trips with non-zero exitstatus' do
      object = described_class.new(exitstatus: 1)
      dumped = described_class::JSON.dump(object).from_right
      loaded = described_class::JSON.load(dumped).from_right

      expect(loaded).to eql(object)
    end
  end
end
