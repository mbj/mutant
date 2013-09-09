# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Blockarg, 'blockarg' do
  let(:source)  { 'foo { |&bar| }' }

  let(:mutations) do
    mutations = []
    mutations << 'foo { |&bar| raise }'
    mutations << 'foo {}'
    mutations << 'foo'
    mutations << 'nil'
  end

  it_should_behave_like 'a mutator'
end
