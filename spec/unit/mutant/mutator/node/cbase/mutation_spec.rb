require 'spec_helper'

describe Mutant::Mutator::Node::NamedValue::Access, 'cbase' do
  let(:source) { '::A' }

  let(:mutations) do
    mutants = []
    mutants << 'nil'
  end

  it_should_behave_like 'a mutator'
end
