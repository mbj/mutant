# frozen_string_literal: true

RSpec.describe Mutant::World do
  subject do
    Mutant::WORLD
  end

  describe '#inspect' do
    def apply
      subject.inspect
    end

    it 'returns expected value' do
      expect(apply).to eql('#<Mutant::World>')
    end

    it 'is frozen' do
      expect(apply.frozen?).to be(true)
    end

    it 'is idempotent' do
      expect(apply).to be(apply)
    end
  end
end
