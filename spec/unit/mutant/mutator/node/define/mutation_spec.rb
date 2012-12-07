require 'spec_helper'

describe Mutant::Mutator, 'define' do

  context 'with no arguments' do
    let(:source) { 'def foo; self.bar; self.baz; end' }

    let(:mutations) do
      mutations = []

      # Mutation of each statement in block
      mutations << 'def foo; bar; self.baz; end'
      mutations << 'def foo; self.bar; baz; end'

      # Remove statement in block
      mutations << 'def foo; self.baz; end'
      mutations << 'def foo; self.bar; end'

      # Remove all statements
      mutations << 'def foo; end'
    end

    it_should_behave_like 'a mutator'
  end

  context 'define on singleton' do
    let(:source) { 'def self.foo; self.bar; self.baz; end' }

    let(:mutations) do
      mutations = []

      # Body presence mutations
      mutations << 'def self.foo; bar; self.baz; end' 
      mutations << 'def self.foo; self.bar; baz; end' 
     
      # Body presence mutations
      mutations << 'def self.foo; self.bar; end'
      mutations << 'def self.foo; self.baz; end'

      # Remove all statements
      mutations << 'def self.foo; end'
    end

    it_should_behave_like 'a mutator'
  end

end
