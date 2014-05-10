# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Literal, 'float' do

  context 'positive number' do
    let(:source) { '10.0' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << '0.0'
      mutations << '1.0'
      mutations << '(0.0 / 0.0)'
      mutations << '(1.0 / 0.0)'
      mutations << '(-1.0 / 0.0)'
      mutations << '-10.0'
    end

    it_should_behave_like 'a mutator'
  end

  context '0.0' do
    let(:source) { '0.0' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << '1.0'
      mutations << '(0.0 / 0.0)'
      mutations << '(1.0 / 0.0)'
      mutations << '(-1.0 / 0.0)'
    end

    it_should_behave_like 'a mutator'
  end

  context '-0.0' do
    let(:source) { '-0.0' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << '1.0'
      mutations << '(0.0 / 0.0)'
      mutations << '(1.0 / 0.0)'
      mutations << '(-1.0 / 0.0)'
    end

    it_should_behave_like 'a mutator'
  end
end
