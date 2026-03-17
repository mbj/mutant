# frozen_string_literal: true

RSpec.describe Mutant::Result::Exception do
  describe '.from_exception' do
    let(:exception) do
      fail ArgumentError, 'test message'
    rescue => error
      error
    end

    def apply
      described_class.from_exception(exception)
    end

    it 'returns exception with string original_class' do
      expect(apply.original_class).to eql('ArgumentError')
    end

    it 'returns exception with message' do
      expect(apply.message).to eql('test message')
    end

    it 'returns exception with backtrace' do
      expect(apply.backtrace).to be_an(Array)
    end
  end

  describe 'JSON round trip' do
    it 'round trips' do
      object = described_class.new(
        backtrace:      %w[first.rb:1 second.rb:2],
        message:        'test error',
        original_class: 'ArgumentError'
      )
      dumped = described_class::JSON.dump(object).from_right
      loaded = described_class::JSON.load(dumped).from_right

      expect(loaded).to eql(object)
    end
  end
end
