# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::NamedValue::Access, 'block_pass' do
  let(:source) { 'foo(&bar)' }

  let(:mutations) do
    mutants = []
    mutants << 'foo'
    mutants << 'nil'
  end

  it_should_behave_like 'a mutator'
end
