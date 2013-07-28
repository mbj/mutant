# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator, 'super' do

  context 'with no arguments' do
    let(:source) { 'super' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
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
end
