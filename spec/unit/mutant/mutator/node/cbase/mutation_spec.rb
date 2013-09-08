# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Noop, 'cbase' do
  let(:source) { '::A' }

  let(:mutations) do
    mutants = []
    mutants << 'nil'
    mutants << 'A'
  end

  it_should_behave_like 'a mutator'
end
