# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Next, 'next' do
  let(:source)  { 'next true' }

  let(:mutations) do
    mutations = []
    mutations << 'next false'
    mutations << 'next nil'
    mutations << 'next'
    mutations << 'nil'
    mutations << 'break true'
  end

  it_should_behave_like 'a mutator'
end
