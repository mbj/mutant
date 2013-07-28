# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator, 'block' do
  context 'with block' do
    let(:source) { 'foo() { a; b }' }

    let(:mutations) do
      mutations = []
      mutations << 'foo { a }'
      mutations << 'foo { b }'
      mutations << 'foo {}'
      mutations << 'foo { raise }'
      mutations << 'foo'
    end

    it_should_behave_like 'a mutator'
  end

  context 'with block args' do

    let(:source) { 'foo { |a, b| }' }

    before do
      Mutant::Random.stub(:hex_string => 'random')
    end

    let(:mutations) do
      mutations = []
      mutations << 'foo'
      mutations << 'foo { |a, b| raise }'
      mutations << 'foo { |a, srandom| }'
      mutations << 'foo { |srandom, b| }'
      mutations << 'foo { |a| }'
      mutations << 'foo { |b| }'
      mutations << 'foo { || }'
    end

    it_should_behave_like 'a mutator'
  end

  context 'with block pattern args' do

    before do
      Mutant::Random.stub(:hex_string => 'random')
    end

    let(:source) { 'foo { |(a, b), c| }' }

    let(:mutations) do
      mutations = []
      mutations << 'foo { || }'
      mutations << 'foo { |a, b, c| }'
      mutations << 'foo { |(a, b), c| raise }'
      mutations << 'foo { |(a), c| }'
      mutations << 'foo { |(b), c| }'
      mutations << 'foo { |(a, b)| }'
      mutations << 'foo { |c| }'
      mutations << 'foo { |(srandom, b), c| }'
      mutations << 'foo { |(a, srandom), c| }'
      mutations << 'foo { |(a, b), srandom| }'
      mutations << 'foo'
    end

    it_should_behave_like 'a mutator'
  end
end
