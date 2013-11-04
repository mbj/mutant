# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Generic, 'ensure' do
  let(:source) { 'begin; rescue; ensure; true; end' }

  let(:mutations) do
    mutations = []
    mutations << 'begin; rescue; ensure; false; end'
    mutations << 'begin; rescue; ensure; nil; end'
    mutations << 'nil'
  end

  it_should_behave_like 'a mutator'
end
