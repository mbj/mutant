# frozen_string_literal: true

RSpec.describe Mutant::Selector::Null do
  describe '#call' do
    subject { described_class.new }

    let(:mutant_subject) { instance_double(Mutant::Subject) }

    def apply
      subject.call(mutant_subject)
    end

    it 'returns no tests' do
      expect(apply).to eql(Mutant::Maybe::Just.new([]))
    end
  end
end
