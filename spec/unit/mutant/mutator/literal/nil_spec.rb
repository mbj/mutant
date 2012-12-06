require 'spec_helper'

describe Mutant::Mutator::Node::Literal, 'nil' do
  let(:source) { 'nil' }

  let(:mutations) do
    mutations = []

    mutations << 'Object.new'
  end

  it_should_behave_like 'a mutator'
end
