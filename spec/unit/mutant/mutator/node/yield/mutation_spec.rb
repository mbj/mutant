require 'spec_helper'

describe Mutant::Mutator::Node::Generic, 'yield' do
  let(:source)  { 'yield true' }

  let(:mutations) do
    mutations = []
    mutations << 'yield false'
    mutations << 'yield nil'
  end

  it_should_behave_like 'a mutator'
end
