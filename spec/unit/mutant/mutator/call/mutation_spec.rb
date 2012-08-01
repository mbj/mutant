require 'spec_helper'

describe Mutant::Mutator, 'call' do
  context 'send without arguments' do
    context 'to self' do

      context 'implict' do
        let(:source) { 'foo' }

        let(:mutations) do
          mutations = []
          # with explicit receiver (not send privately)
          mutations << 'self.foo' 
        end

        it_should_behave_like 'a mutation enumerator method'
      end

      context 'explict' do
        let(:source) { 'self.foo' }

        it_should_behave_like 'a noop mutation enumerator method'
      end
    end
  end

  context 'send with arguments' do
    context 'to self' do
      context 'implicit' do
        let(:source) { 'foo(1)' }

        let(:mutations) do
          mutations = []
          # with explicit receiver (not send privately)
          mutations << 'self.foo(1)'
        end

        it_should_behave_like 'a mutation enumerator method'
      end

      context 'explicit' do
        let(:source) { 'self.foo(1)' }

        it_should_behave_like 'a noop mutation enumerator method'
      end
    end
  end
end
