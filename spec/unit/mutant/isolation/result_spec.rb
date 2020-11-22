# frozen_string_literal: true

RSpec.describe Mutant::Isolation::Result do
  let(:object) do
    described_class.new(
      exception:      exception,
      log:            '',
      process_status: process_status,
      timeout:        timeout,
      value:          nil
    )
  end

  describe '#valid_value?' do
    let(:exception)       { nil  }
    let(:timeout)         { nil  }
    let(:process_success) { true }

    let(:process_status) do
      instance_double(
        Process::Status,
        success?: process_success
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
end
