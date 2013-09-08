# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Restarg, 'restarg' do
  let(:source) { 'foo(*bar)' }

  let(:mutations) do
    mutants = []
    mutants << 'foo'
    mutants << 'foo(nil)'
    mutants << 'foo(bar)'
    mutants << 'foo(*nil)'
    mutants << 'nil'
  end

  it_should_behave_like 'a mutator'
end
