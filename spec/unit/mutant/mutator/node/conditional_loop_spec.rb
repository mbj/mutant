# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::ConditionalLoop do

  context 'with empty body' do
    let(:source) { 'while true; end' }

    let(:mutations) do
      mutations = []
      mutations << 'while true; raise; end'
      mutations << 'while false; end'
      mutations << 'while nil; end'
      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'with while statement' do
    let(:source) { 'while true; foo; bar; end' }

    let(:mutations) do
      mutations = []
      mutations << 'while true; bar; end'
      mutations << 'while true; foo; end'
      mutations << 'while true; end'
      mutations << 'while false; foo; bar; end'
      mutations << 'while nil;   foo; bar; end'
      mutations << 'while true;  foo; nil; end'
      mutations << 'while true;  nil; bar; end'
      mutations << 'while true;  raise; end'
      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'with until statement' do
    let(:source) { 'until true; foo; bar; end' }

    let(:mutations) do
      mutations = []
      mutations << 'until true; bar; end'
      mutations << 'until true; foo; end'
      mutations << 'until true; end'
      mutations << 'until false; foo; bar; end'
      mutations << 'until nil;   foo; bar; end'
      mutations << 'until true;  foo; nil; end'
      mutations << 'until true;  nil; bar; end'
      mutations << 'until true;  raise; end'
      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end
end
