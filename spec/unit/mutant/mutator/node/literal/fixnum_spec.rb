# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Literal, 'fixnum' do
  let(:source) { '10' }

  let(:mutations) do
    %W(nil 0 1 -10 9 11)
  end

  it_should_behave_like 'a mutator'
end
