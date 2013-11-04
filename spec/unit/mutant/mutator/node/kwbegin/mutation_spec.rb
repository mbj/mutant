# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Kwbegin, 'kwbegin' do
  let(:source) { 'begin; true; end' }

  let(:mutations) do
    mutations = []
    mutations << 'begin; false; end'
    mutations << 'begin; nil; end'
    mutations << 'nil'
  end

  it_should_behave_like 'a mutator'
end
