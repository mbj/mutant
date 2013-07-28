# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::NamedValue::VariableAssignment, 'mutations' do
  before do
    Mutant::Random.stub(:hex_string => 'random')
  end

  let(:source) { 'A = true' }

  let(:mutations) do
    mutations = []

    mutations << 'SRANDOM = true'
    mutations << 'A = false'
    mutations << 'A = nil'
  end

  it_should_behave_like 'a mutator'
end
