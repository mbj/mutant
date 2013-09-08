# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Generic, 'dsum' do
  before do
    Mutant::Random.stub(hex_string: 'random')
  end

  let(:source)  { ':"foo#{bar}baz"' }

  let(:mutations) do
    mutations = []
    mutations << ':"random#{bar}baz"'
    mutations << ':"#{nil}#{bar}baz"'
    mutations << ':"foo#{bar}random"'
    mutations << ':"foo#{bar}#{nil}"'
    mutations << ':"foo#{nil}baz"'
  end

  it_should_behave_like 'a mutator'
end
