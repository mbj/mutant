require 'spec_helper'

describe Mutant::Mutator, 'send' do
  context 'send without arguments' do
    # This could not be reproduced in a test case but happens in the mutant source code?
    context 'block_given?' do
      context 'implicit self' do
        let(:source) { 'block_given?' }

        it_should_behave_like 'a noop mutator'
      end
      
      context 'explicit self' do
        let(:source) { 'self.block_given?' }

        it_should_behave_like 'a noop mutator'
      end
    end

    context 'with self as receiver' do

      context 'implicit' do
        let(:source) { 'foo' }

        it_should_behave_like 'a noop mutator'
      end

      context 'explict' do
        let(:source) { 'self.foo' }

        let(:mutations) do
          mutations = []
          # with implicit receiver (send privately)
          mutations << 'foo' 
        end

        it_should_behave_like 'a mutator'
      end
    end

    context 'to some object' do
      let(:source) { '1.foo' }

      it_should_behave_like 'a noop mutator'
    end
  end

  context 'send with arguments' do

    context 'one argument' do
      let(:source) { 'foo(nil)' }

      let(:mutations) do 
        mutations = []
        mutations << 'foo()'
        mutations << 'foo(Object.new)'
      end

      it_should_behave_like 'a mutator'
    end

    context 'two arguments' do
      let(:source) { 'foo(nil, nil)' }

      let(:mutations) do 
        mutations = []
        mutations << 'foo()'
        mutations << 'foo(nil)'
        mutations << 'foo(Object.new, nil)'
        mutations << 'foo(nil, Object.new)'
      end

      it_should_behave_like 'a mutator'
    end

    context 'with block' do
      let(:source) { 'foo() { a; b }' }

      let(:mutations) do 
        mutations = []
        mutations << 'foo() { a }'
        mutations << 'foo() { b }'
        mutations << 'foo() { }'
        mutations << 'foo'
      end

      it_should_behave_like 'a mutator'
    end

    context 'with block args' do

      let(:source) { 'foo { |a, b| }' }

      before do
        Mutant::Random.stub(:hex_string => :random)
      end

      let(:mutations) do 
        mutations = []
        mutations << 'foo'
        mutations << 'foo() { |a, b| Object.new }'
        mutations << 'foo() { |a, srandom| }'
        mutations << 'foo() { |srandom, b| }'
        mutations << 'foo() { |a| }'
        mutations << 'foo() { |b| }'
        mutations << 'foo() { || }'
      end

      it_should_behave_like 'a mutator'
    end

    context 'with block pattern args' do

      before do
        Mutant::Random.stub(:hex_string => :random)
      end

      let(:source) { 'foo { |(a, b), c| }' }

      let(:mutations) do 
        mutations = []
        mutations << 'foo() { || }'
        mutations << 'foo() { |a, b, c| }'
        mutations << 'foo() { |(a, b), c| Object.new }'
        mutations << 'foo() { |(a, b)| }'
        mutations << 'foo() { |c| }'
        mutations << 'foo() { |(srandom, b), c| }'
        mutations << 'foo() { |(a, srandom), c| }'
        mutations << 'foo() { |(a, b), srandom| }'
        mutations << 'foo'
      end

      it_should_behave_like 'a mutator'
    end

  end
end
