require 'spec_helper'

describe Mutant::Mutator, 'super' do

  context 'with no arguments' do
    let(:source) { 'super' }

    let(:mutations) do
      mutations = []
      mutations << 'super()'
    end

    it_should_behave_like 'a mutator'
  end

  context 'with explicit empty arguments' do
    let(:source) { 'super()' }

    let(:mutations) do
      mutations = []
      mutations << 'super'
    end

    it_should_behave_like 'a mutator'
  end

  context 'with explicit empty arguments and block' do
    let(:source) { 'super() { foo; bar }' }

    let(:mutations) do
      mutations = []
      mutations << 'super() { foo }'
      mutations << 'super() { bar }'
      mutations << 'super() { }'
      mutations << 'super()'
      mutations << 'super'
    end

    it_should_behave_like 'a mutator'
  end

  context 'super with arguments' do
    let(:source) { 'super(foo, bar)' }

    let(:mutations) do
      mutations = []
      mutations << 'super'
      mutations << 'super()'
      mutations << 'super(foo)'
      mutations << 'super(bar)'
    end

    it_should_behave_like 'a mutator'
  end

  context 'super with arguments and block' do
    let(:source) { 'super(foo, bar) { foo; bar }' }

    let(:mutations) do
      mutations = []
      mutations << 'super(foo, bar) { foo; }'
      mutations << 'super(foo, bar) { bar; }'
      mutations << 'super(foo, bar) { nil }'
      mutations << 'super(foo, bar)'
      mutations << 'super'
      mutations << 'super(foo) { foo; bar }'
      mutations << 'super(bar) { foo; bar }'
      mutations << 'super() { foo; bar }'
    end

    it_should_behave_like 'a mutator'
  end
end
