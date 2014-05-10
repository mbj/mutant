# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Literal, 'string' do
  let(:random_string) { 'bar' }

  let(:source) { '"foo"' }

  let(:mutations) do
    %W(nil)
  end

  it_should_behave_like 'a mutator'
end
