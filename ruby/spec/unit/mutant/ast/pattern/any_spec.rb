# frozen_string_literal: true

RSpec.describe Mutant::AST::Pattern::Any do
  describe '#match?' do
    it 'returns true' do
      expect(subject.match?(s(:true))).to be(true)
    end
  end
end
