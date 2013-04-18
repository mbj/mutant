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

  context 'with arguments' do
    let(:source) { 'def foo(a, b); nil; end' }

    before do
      Mutant::Random.stub(:hex_string => 'random')
    end

    let(:mutations) do
      mutations = []

      # Deletion of each argument
      mutations << 'def foo(a); nil; end'
      mutations << 'def foo(b); nil; end'

      # Deletion of all arguments
      mutations << 'def foo; nil; end'

      # Rename each argument
      mutations << 'def foo(srandom, b); nil; end'
      mutations << 'def foo(a, srandom); nil; end'

      # Mutation of body
      mutations << 'def foo(a, b); Object.new; end'
    end

    it_should_behave_like 'a mutator'
  end

  context 'with arguments beginning with an underscore' do
    let(:source) { 'def foo(_unused); end' }

    let(:mutations) do
      mutations = []
      mutations << 'def foo(_unused); Object.new; end'
      mutations << 'def foo; end'
    end

    it_should_behave_like 'a mutator'
  end

  context 'default argument' do
    let(:source) { 'def foo(a = "literal"); end' }

    before do
      Mutant::Random.stub(:hex_string => 'random')
    end

    let(:mutations) do
      mutations = []
      mutations << 'def foo(a); end'
      mutations << 'def foo(); end'
      mutations << 'def foo(a = "random"); end'
      mutations << 'def foo(a = nil); end'
      mutations << 'def foo(a = "literal"); Object.new; end'
      mutations << 'def foo(srandom = "literal"); nil; end'
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

  context 'define on singleton with argument' do

    before do
      Mutant::Random.stub(:hex_string => 'random')
    end

    let(:source) { 'def self.foo(a, b); nil; end' }

    let(:mutations) do
      mutations = []

      # Deletion of each argument
      mutations << 'def self.foo(a); nil; end'
      mutations << 'def self.foo(b); nil; end'

      # Deletion of all arguments
      mutations << 'def self.foo; nil; end'

      # Rename each argument
      mutations << 'def self.foo(srandom, b); nil; end'
      mutations << 'def self.foo(a, srandom); nil; end'

      # Mutation of body
      mutations << 'def self.foo(a, b); Object.new; end'
    end

    it_should_behave_like 'a mutator'
  end
end
