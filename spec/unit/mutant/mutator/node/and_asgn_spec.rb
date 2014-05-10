# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::OpAsgn, 'and_asgn' do
  let(:source)  { 'a &&= 1' }

  let(:mutations) do
    mutations = []
    mutations << 'a__mutant__ &&= 1'
    mutations << 'a &&= nil'
    mutations << 'a &&= 0'
    mutations << 'a &&= -1'
    mutations << 'a &&= 2'
    mutations << 'nil'
  end

  it_should_behave_like 'a mutator'
end
