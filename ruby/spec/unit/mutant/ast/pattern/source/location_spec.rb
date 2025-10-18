# frozen_string_literal: true

RSpec.describe Mutant::AST::Pattern::Source::Location do
  let(:instance) do
    described_class.new(
      line_index: 1,
      line_start: 1,
      range:      3..4,
      source:
    )
  end

  let(:source) do
    Mutant::AST::Pattern::Source.new(string: "\n1234")
  end

  describe '#display' do
    def apply
      instance.display
    end

    it 'returns expected value' do
      expect(apply).to eql("1234\n  ^^")
    end
  end
end
