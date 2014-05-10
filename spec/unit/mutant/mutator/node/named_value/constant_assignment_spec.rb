# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::NamedValue::VariableAssignment, 'mutations' do
  let(:source) { 'A = true' }

  let(:mutations) do
    mutations = []
    mutations << 'A__MUTANT__ = true'
    mutations << 'A = false'
    mutations << 'A = nil'
  end

  it_should_behave_like 'a mutator'
end
