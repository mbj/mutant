# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Return do

  context 'return without value' do
    let(:source) { 'return' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'return with value' do
    let(:source) { 'return foo' }

    let(:mutations) do
      mutations = []
      mutations << 'foo'
      mutations << 'return nil'
      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'return as last expression in a block with explicit return value' do
    let(:source) { 'foo; return false' }

    context 'with default config' do

      let(:mutations) do
        mutations = []
        mutations << 'foo'
        mutations << 'return false'
        mutations << 'nil; return false'
        mutations << 'foo; return nil'
        mutations << 'foo; return true'
        mutations << 'foo; false'
        mutations << 'foo; nil'
      end

      it_should_behave_like 'a mutator'

    end

    context 'with config where return value propagation is disabled' do
      let(:config) do
        Mutant::Mutator::Config::DEFAULT.update(
          return_as_last_block_statement_value_propagation: false
        )
      end

      context 'and no other return lives within the same block' do

        let(:mutations) do
          mutations = []
          mutations << 'foo'
          mutations << 'return false'
          mutations << 'nil; return false'
          mutations << 'foo; return nil'
          mutations << 'foo; return true'
          mutations << 'foo; nil'
        end

        it_should_behave_like 'a mutator'

      end

      context 'and another eql return lives within the same block' do

        # Thise one proves we pick the correct last expression to disable return value propagation
        let(:source) { 'return false; return false' }

        let(:mutations) do
          mutations = []
          mutations << 'return true; return false'
          mutations << 'return nil; return false'
          mutations << 'return false; return true'
          mutations << 'return false; return nil'
          mutations << 'return false'
          mutations << 'return false; nil'
          mutations << 'nil; return false'
          mutations << 'false; return false'
        end

        it_should_behave_like 'a mutator'

      end
    end
  end

  context 'return NOT as last expression in a block' do
    let(:source) { 'return; foo' }

    let(:mutations) do
      mutations = []
      mutations << 'nil; foo'
      mutations << 'return; nil'
      mutations << 'foo'
      mutations << 'return'
    end

    it_should_behave_like 'a mutator'
  end

end
