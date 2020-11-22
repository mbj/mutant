# frozen_string_literal: true

RSpec.describe Mutant::Isolation::Fork, mutant: false do
  def apply(&block)
    Mutant::Config::DEFAULT.isolation.call(timeout, &block)
  end

  let(:timeout) { nil }

  it 'isolates local writes' do
    a = 1

    expect { apply { a = 2 } }.to_not(change { a }.from(1))
  end

  it 'captures console output' do
    result = apply do
      $stdout.puts('foo')
      $stderr.puts('bar')
    end

    expect(result.log).to eql("foo\nbar\n")
  end

  it 'allows to read result' do
    result = apply { :foo }

    expect(result.value).to eql(:foo)
  end

  context 'with configured timeout' do
    let(:timeout) { 0.1 }

    context 'when block exits within timeout' do
      def apply
        super do
          :value
        end
      end

      it 'returns successful result' do
        result = apply
        expect(result.timeout).to be(nil)
        expect(result.value).to be(:value)
      end
    end

    context 'when block does not exit within timeout' do
      def apply
        super do
          sleep 10
          :value
        end
      end

      it 'returns successful result' do
        result = apply
        expect(result.timeout).to be(0.1)
        expect(result.value).to be(nil)
      end
    end
  end
end
