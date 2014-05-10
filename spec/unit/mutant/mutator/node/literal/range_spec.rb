# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Literal, 'range' do

  context 'inclusive range literal' do
    let(:source) { '1..100' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << '1...100'
      mutations << '(0.0 / 0.0)..100'
      mutations << '1..(1.0 / 0.0)'
      mutations << '1..(0.0 / 0.0)'
      mutations << '-1..100'
      mutations << '0..100'
      mutations << '2..100'
      mutations << 'nil..100'
      mutations << '1..nil'
      mutations << '1..0'
      mutations << '1..1'
      mutations << '1..99'
      mutations << '1..101'
      mutations << '1..-100'
    end

    it_should_behave_like 'a mutator'
  end

  context 'exclusive range literal' do
    let(:source) { '1...100' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << '1..100'
      mutations << '(0.0 / 0.0)...100'
      mutations << '1...(1.0 / 0.0)'
      mutations << '1...(0.0 / 0.0)'
      mutations << '-1...100'
      mutations << '0...100'
      mutations << '2...100'
      mutations << 'nil...100'
      mutations << '1...nil'
      mutations << '1...0'
      mutations << '1...1'
      mutations << '1...99'
      mutations << '1...101'
      mutations << '1...-100'
    end

    it_should_behave_like 'a mutator'
  end
end
