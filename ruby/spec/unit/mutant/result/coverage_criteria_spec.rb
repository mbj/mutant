# frozen_string_literal: true

RSpec.describe Mutant::Result::CoverageCriteria do
  let(:object) do
    described_class.new(
      process_abort:,
      test_result:,
      timeout:
    )
  end

  let(:timeout)       { false }
  let(:test_result)   { false }
  let(:process_abort) { false }

  describe '#success?' do
    def apply
      object.success?
    end

    context 'on no success criteria set' do
      it 'returns false' do
        expect(apply).to be(false)
      end
    end

    context 'on timeout criteria set' do
      let(:timeout) { true }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end

    context 'on test result criteria set' do
      let(:test_result) { true }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end

    context 'on process_abort criteria set' do
      let(:process_abort) { true }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end
  end
end
