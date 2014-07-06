require 'spec_helper'

describe Mutant::Isolation::None do
  before do
    @initial = 1
  end

  describe '.run' do
    let(:object) { described_class }

    it 'does not isolate side effects' do
      object.call { @initial = 2 }
      expect(@initial).to be(2)
    end

    it 'return block value' do
      expect(object.call { :foo }).to be(:foo)
    end

  end
end

describe Mutant::Isolation::Fork do
  before do
    @initial = 1
  end

  describe '.run' do
    let(:object) { described_class }

    it 'does isolate side effects' do
      object.call { @initial = 2  }
      expect(@initial).to be(1)
    end

    it 'return block value' do
      expect(object.call { :foo }).to be(:foo)
    end

  end
end
