require 'spec_helper'

describe Mutant::Isolation do
  describe '.run' do
    let(:object) { described_class }

    it 'isolates global effects from process' do
      expect { object.call { ::Foo = 1 } }.not_to change { defined?(Foo) }.from(nil)
    end

    it 'return block value' do
      expect(object.call { :foo }).to be(:foo)
    end

  end
end
