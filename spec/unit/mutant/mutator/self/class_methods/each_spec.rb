require 'spec_helper'

describe Mutant::Mutator::Self, '.each' do
  let(:source) { 'self' }

  let(:mutations) do
    mutations = []
  end

  it_should_behave_like 'a mutation enumerator method'
end
