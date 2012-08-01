require 'spec_helper'

describe Mutant::Mutator::Literal, 'range' do
  context 'inclusive range literal' do
    let(:source) { '1..100' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << '1...100'
      mutations << '(0.0/0.0)..100'
      mutations << [:dot2, [:negate, [:call, [:lit, 1.0], :/, [:arglist, [:lit, 0.0]]]], [:lit, 100]]
      mutations << '1..(1.0/0.0)'
      mutations << '1..(0.0/0.0)'
    end

    it_should_behave_like 'a mutation enumerator method'
  end

  context 'exclusive range literal' do
    let(:source) { '1...100' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << '1..100'
      mutations << '(0.0/0.0)...100'
      mutations << [:dot3, [:negate, [:call, [:lit, 1.0], :/, [:arglist, [:lit, 0.0]]]], [:lit, 100]]
      mutations << '1...(1.0/0.0)'
      mutations << '1...(0.0/0.0)'
    end

    it_should_behave_like 'a mutation enumerator method'
  end
end
