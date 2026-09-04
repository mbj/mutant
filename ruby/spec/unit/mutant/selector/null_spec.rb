# frozen_string_literal: true

RSpec.describe Mutant::Selector::Null do
  describe '#name' do
    it 'returns the strategy name' do
      expect(described_class.new.name).to eql('null')
    end
  end

  describe '#call' do
    subject { described_class.new }

    let(:mutant_subject) { instance_double(Mutant::Subject) }

    def apply
      subject.call(mutant_subject)
    end

    it 'returns no tests' do
      expect(apply).to eql([])
    end
  end
end
