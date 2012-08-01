require 'spec_helper'

describe Mutant::Mutator::Literal, 'regex' do
  let(:random_string) { 'bar' }

  let(:source) { '/foo/' }

  let(:base_mutations) do
    mutations = []
    mutations << 'nil'
    mutations << "/#{random_string}/"
  end

  before do
    Mutant::Random.stub(:hex_string => random_string)
  end

  let(:mutations) { base_mutations }

  it_should_behave_like 'a mutation enumerator method'

  context 'when source is empty regexp' do
    before do
      pending
    end

    let(:source) { '//' }

    let(:mutations) { base_mutations - [source.to_ast] }

    it_should_behave_like 'a mutation enumerator method'
  end
end
