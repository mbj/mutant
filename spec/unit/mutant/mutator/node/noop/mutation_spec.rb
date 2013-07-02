require 'spec_helper'

# FIXME: This spec needs to be structured better!
describe Mutant::Mutator::Node::Noop, 'send' do

  let(:source) { 'alias foo bar' }

  let(:mutations) do
    mutations = []
  end

  it_should_behave_like 'a mutator'
end
