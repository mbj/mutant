# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Generic, 'redo' do
  let(:source)    { 'redo' }
  let(:mutations) { []     }

  it_should_behave_like 'a mutator'
end
