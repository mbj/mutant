# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Literal, 'nil' do
  let(:source)    { 'nil' }
  let(:mutations) { []    }

  it_should_behave_like 'a mutator'
end
