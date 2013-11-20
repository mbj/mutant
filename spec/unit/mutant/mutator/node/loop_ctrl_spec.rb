# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::LoopControl do

  context 'with break node' do
    let(:source) { 'break true' }

    let(:mutations) do
      mutations = []
      mutations << 'break false'
      mutations << 'break nil'
      mutations << 'break'
      mutations << 'nil'
      mutations << 'next true'
    end

    it_should_behave_like 'a mutator'

  end

  context 'with next node' do
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
end
