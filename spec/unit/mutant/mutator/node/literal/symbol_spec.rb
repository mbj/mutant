# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Literal, 'symbol' do
  let(:random_string) { 'bar' }

  let(:source) { ':foo' }

  let(:mutations) do
    %w(nil) << ":s#{random_string}"
  end

  before do
    Mutant::Random.stub(hex_string: random_string)
  end

  it_should_behave_like 'a mutator'
end
