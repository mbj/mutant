# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Generic, 'break' do
  let(:source)    { 'break true' }

  let(:mutations) do
    mutations = []
    mutations << 'break false'
    mutations << 'break nil'
  end

  it_should_behave_like 'a mutator'
end
