# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator, 'arguments' do
  before do
    Mutant::Random.stub(hex_string: 'random')
  end

  context 'with underscore' do
    let(:source) { 'def foo(a, _b, _); end' }

    let(:mutations) do
      mutations = []
      mutations << 'def foo(srandom, _b, _); end'
      mutations << 'def foo(); end'
      mutations << 'def foo(_b, _); end'
      mutations << 'def foo(a, _b, _); raise; end'
    end

    it_should_behave_like 'a mutator'
  end
end
