require 'spec_helper'

describe Mutant::Mutator::Literal::EmptyArray,'.each' do
  context 'empty array literal' do
    let(:source) { '[]' }

    let(:mutations) do
      mutations = []

      # Literal replaced with nil
      mutations << [:nil]

      # Extra element
      mutations << '[nil]'
    end

    it_should_behave_like 'a mutation enumerator method'
  end
end
