# frozen_string_literal: true

RSpec.describe Mutant::Isolation::None do
  let(:timeout) { nil }

  describe '.call' do
    let(:object) { described_class.new }

    context 'without exception' do
      it 'returns success result' do
        expect(object.call(timeout) { :foo }).to eql(
          Mutant::Isolation::Result.new(
            exception:      nil,
            log:            '',
            process_status: nil,
            timeout:        nil,
            value:          :foo
          )
        )
      end
    end

    context 'with exception' do
      let(:exception) { RuntimeError.new('foo') }

      it 'returns error result' do
        expect(object.call(timeout) { fail exception }).to eql(
          Mutant::Isolation::Result.new(
            exception:,
            log:            '',
            process_status: nil,
            timeout:        nil,
            value:          nil
          )
        )
      end
    end
  end
end
