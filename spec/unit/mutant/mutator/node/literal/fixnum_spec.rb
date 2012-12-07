require 'spec_helper'

describe Mutant::Mutator::Node::Literal, 'fixnum' do
  let(:random_fixnum) { 5 }

  let(:source) { '10' }

  let(:mutations) do
    %W(nil 0 1 #{random_fixnum} -10)
  end

  before do
    Mutant::Random.stub(:fixnum => random_fixnum)
  end

  it_should_behave_like 'a mutator'
end
