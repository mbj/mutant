# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Generic, 'rescue' do
  let(:source) { 'begin; rescue Exception => e; true end' }

  let(:mutations) do
    mutations = []
    mutations << 'begin; rescue Exception => srandom; true; end'
    mutations << 'begin; rescue Exception => e; false; end'
    mutations << 'begin; rescue Exception => e; nil; end'
    mutations << 'begin; rescue nil => e; true; end'
#    mutations << 'begin; rescue => e; true; end'  # FIXME
  end

  before do
    Mutant::Random.stub(:hex_string => 'random')
  end

  pending do
    it_should_behave_like 'a mutator'
  end
end
