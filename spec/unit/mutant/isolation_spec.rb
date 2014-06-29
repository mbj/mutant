require 'spec_helper'

describe Mutant::Isolation do
  describe '.run' do
    let(:object) { described_class }

    it 'isolates global effects from process' do
      expect(defined?(::TestConstant)).to be(nil)
      object.call { ::TestConstant = 1 }
      expect(defined?(::TestConstant)).to be(nil)
    end

    it 'return block value' do
      expect(object.call { :foo }).to be(:foo)
    end

  end
end
