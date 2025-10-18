# frozen_string_literal: true

RSpec.describe Mutant::AST::Pattern::None do
  describe '#match?' do
    it 'returns true' do
      expect(subject.match?(s(:true))).to be(false)
    end
  end
end
