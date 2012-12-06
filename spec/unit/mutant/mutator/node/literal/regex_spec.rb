require 'spec_helper'

describe Mutant::Mutator::Node::Literal, 'regex' do
  let(:random_string) { 'bar' }

  let(:source) { '/foo/' }

  let(:base_mutations) do
    mutations = []
    mutations << 'nil'
    mutations << "/#{random_string}/"
    mutations << '//' # match all
    mutations << '/a\A/' # match nothing
  end

  before do
    Mutant::Random.stub(:hex_string => random_string)
  end

  let(:mutations) { base_mutations }

  it_should_behave_like 'a mutator'
end
