# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Generic, 'next' do
  let(:source)  { 'next true' }

  let(:mutations) do
    mutations = []
    mutations << 'next false'
    mutations << 'next nil'
  end

  it_should_behave_like 'a mutator'
end
