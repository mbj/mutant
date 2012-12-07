require 'spec_helper'

describe Mutant::Mutator::Node::Literal, 'empty array' do
  let(:source) { '[]' }

  let(:mutations) do
    mutations = []

    # Literal replaced with nil
    mutations << 'nil'

    # Extra element
    mutations << '[nil]'
  end

  it_should_behave_like 'a mutator'
end
