require 'spec_helper'

describe Mutant::Mutator, 'call' do
  context 'send without arguments' do
    # This could not be reproduced in a test case but happens in the mutant source code?
    context 'block given' do
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
    context 'with self as receiver' do
      context 'implicit' do
        let(:source) { 'foo(1)' }

        it_should_behave_like 'a noop mutator'
      end

      context 'explicit' do
        let(:source) { 'self.foo(1)' }

        let(:mutations) do
          mutations = []
          # with implicit receiver (send privately)
          mutations << 'foo(1)'
        end

        it_should_behave_like 'a mutator'
      end
    end
  end
end
