# frozen_string_literal: true

RSpec.describe Mutant::Isolation::Result do
  let(:object) do
    described_class.new(
      exception:,
      log:            Mutant::LogCapture::String.new(content: ''),
      process_status:,
      timeout:,
      value:          nil
    )
  end

  describe '#valid_value?' do
    let(:exception)       { nil  }
    let(:timeout)         { nil  }
    let(:process_success) { true }

    let(:process_status) do
      Mutant::Result::ProcessStatus.new(
        exitstatus: process_success ? 0 : 1
      )
    end

    def apply
      object.valid_value?
    end

    context 'no contraindications' do
      it 'returns true' do
        expect(apply).to be(true)
      end
    end

    context 'with timeout' do
      let(:timeout) { 1.0 }

      it 'returns false' do
        expect(apply).to be(false)
      end
    end

    context 'with exception' do
      let(:exception) { RuntimeError.new }

      it 'returns false' do
        expect(apply).to be(false)
      end
    end

    context 'without process status' do
      let(:process_status) { nil }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end

    context 'without error process status' do
      let(:process_success) { false }

      it 'returns true' do
        expect(apply).to be(false)
      end
    end
  end

  describe 'JSON round trip' do
    it 'round trips with all fields present' do
      object = described_class.new(
        exception:      Mutant::Result::Exception.new(backtrace: %w[a.rb:1], message: 'boom',
                                                      original_class: 'RuntimeError'),
        log:            Mutant::LogCapture::String.new(content: 'some log'),
        process_status: Mutant::Result::ProcessStatus.new(exitstatus: 1),
        timeout:        2.5,
        value:          Mutant::Result::Test.new(
          job_index: 0,
          output:    Mutant::LogCapture::String.new(content: 'ok'),
          passed:    true,
          runtime:   1.0
        )
      )

      dumped = described_class::CODEC.dump(object).from_right
      loaded = described_class::CODEC.load(dumped).from_right

      expect(loaded).to eql(object)
    end

    it 'round trips with nil fields' do
      object = described_class.new(
        exception:      nil,
        log:            Mutant::LogCapture::String.new(content: ''),
        process_status: nil,
        timeout:        nil,
        value:          nil
      )

      dumped = described_class::CODEC.dump(object).from_right
      loaded = described_class::CODEC.load(dumped).from_right

      expect(loaded).to eql(object)
    end

    it 'round trips with only exception present' do
      object = described_class.new(
        exception:      Mutant::Result::Exception.new(backtrace: [], message: 'err', original_class: 'StandardError'),
        log:            Mutant::LogCapture::String.new(content: ''),
        process_status: nil,
        timeout:        nil,
        value:          nil
      )

      dumped = described_class::CODEC.dump(object).from_right
      loaded = described_class::CODEC.load(dumped).from_right

      expect(loaded).to eql(object)
    end

    it 'round trips with only process_status present' do
      object = described_class.new(
        exception:      nil,
        log:            Mutant::LogCapture::String.new(content: ''),
        process_status: Mutant::Result::ProcessStatus.new(exitstatus: 0),
        timeout:        nil,
        value:          nil
      )

      dumped = described_class::CODEC.dump(object).from_right
      loaded = described_class::CODEC.load(dumped).from_right

      expect(loaded).to eql(object)
    end

    it 'round trips with only timeout present' do
      object = described_class.new(
        exception:      nil,
        log:            Mutant::LogCapture::String.new(content: ''),
        process_status: nil,
        timeout:        5.0,
        value:          nil
      )

      dumped = described_class::CODEC.dump(object).from_right
      loaded = described_class::CODEC.load(dumped).from_right

      expect(loaded).to eql(object)
    end

    it 'round trips with only value present' do
      object = described_class.new(
        exception:      nil,
        log:            Mutant::LogCapture::String.new(content: ''),
        process_status: nil,
        timeout:        nil,
        value:          Mutant::Result::Test.new(
          job_index: nil,
          output:    Mutant::LogCapture::String.new(content: ''),
          passed:    false,
          runtime:   0.0
        )
      )

      dumped = described_class::CODEC.dump(object).from_right
      loaded = described_class::CODEC.load(dumped).from_right

      expect(loaded).to eql(object)
    end
  end
end
