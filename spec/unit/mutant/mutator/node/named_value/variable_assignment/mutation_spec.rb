require 'spec_helper'

describe Mutant::Mutator::Node::NamedValue::VariableAssignment, 'mutations' do
  before do
    Mutant::Random.stub(:hex_string => :random)
  end

  context 'global variable' do
    let(:source) { '$a = true' }

    let(:mutations) do
      mutations = []

      mutations << '$srandom = true'
      mutations << '$a = false'
      mutations << '$a = nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'class variable' do
    let(:source) { '@@a = true' }

    let(:mutations) do
      mutations = []

      mutations << '@@srandom = true'
      mutations << '@@a = false'
      mutations << '@@a = nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'instance variable' do
    let(:source) { '@a = true' }

    let(:mutations) do
      mutations = []

      mutations << '@srandom = true'
      mutations << '@a = false'
      mutations << '@a = nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'local variable' do
    let(:source) { 'a = true' }

    let(:mutations) do
      mutations = []

      mutations << 'srandom = true'
      mutations << 'a = false'
      mutations << 'a = nil'
    end

    it_should_behave_like 'a mutator'
  end
end
