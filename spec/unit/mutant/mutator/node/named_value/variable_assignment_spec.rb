# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::NamedValue::VariableAssignment, 'mutations' do
  context 'global variable' do
    let(:source) { '$a = true' }

    let(:mutations) do
      mutations = []
      mutations << '$a__mutant__ = true'
      mutations << '$a = false'
      mutations << '$a = nil'
      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'class variable' do
    let(:source) { '@@a = true' }

    let(:mutations) do
      mutations = []
      mutations << '@@a__mutant__ = true'
      mutations << '@@a = false'
      mutations << '@@a = nil'
      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'instance variable' do
    let(:source) { '@a = true' }

    let(:mutations) do
      mutations = []
      mutations << '@a__mutant__ = true'
      mutations << '@a = false'
      mutations << '@a = nil'
      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'local variable' do
    let(:source) { 'a = true' }

    let(:mutations) do
      mutations = []
      mutations << 'a__mutant__ = true'
      mutations << 'a = false'
      mutations << 'a = nil'
      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end
end
