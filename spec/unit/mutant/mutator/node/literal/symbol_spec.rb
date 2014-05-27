# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Literal, 'symbol' do
  let(:random_string) { 'bar' }

  let(:source) { ':foo' }

  let(:mutations) do
    %w[nil :foo__mutant__]
  end

  it_should_behave_like 'a mutator'
end
