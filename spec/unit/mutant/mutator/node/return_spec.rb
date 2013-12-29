# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator, 'return' do

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

end
