require 'spec_helper'

describe Mutant::Mutator::Node::NamedValue::Access, 'cbase' do

  before do
    Mutant::Random.stub(:hex_string => :random)
  end

  let(:source) { '::A' }

  let(:mutations) do
    mutants = []
    mutants << 'nil'
  end

  it_should_behave_like 'a mutator'
end
