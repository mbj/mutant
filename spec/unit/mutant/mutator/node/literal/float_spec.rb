# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Literal, 'float' do

  before do
    Mutant::Random.stub(float: random_float)
  end

  let(:random_float) { 7.123 }

  context 'positive number' do
    let(:source) { '10.0' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << '0.0'
      mutations << '1.0'
      mutations << random_float.to_s
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
      mutations << random_float.to_s
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
      mutations << random_float.to_s
      mutations << '(0.0 / 0.0)'
      mutations << '(1.0 / 0.0)'
      mutations << '(-1.0 / 0.0)'
    end

    it_should_behave_like 'a mutator'
  end
end
