# frozen_string_literal: true

RSpec.describe Mutant::Isolation::None do
  let(:timeout) { nil }

  describe '.call' do
    let(:object) { described_class.new }

    context 'without exception' do
      it 'returns success result' do
        expect(object.call(timeout) { :foo })
          .to eql(Mutant::Isolation::Result::Success.new(:foo))
      end
    end

    context 'with exception' do
      let(:exception) { RuntimeError.new('foo') }

      it 'returns error result' do
        expect(object.call(timeout) { fail exception })
          .to eql(Mutant::Isolation::Result::Exception.new(exception))
      end
    end
  end
end
