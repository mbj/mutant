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
    end

    it_should_behave_like 'a mutator'
  end
end
