# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Generic, 'rescue' do
  let(:source) { 'begin; rescue Exception => e; end' }

  let(:mutations) do
    mutations = []
    mutations << 'begin; rescue Exception => srandom; end'
    mutations << 'begin; rescue nil => e; end'
    mutations << 'begin; rescue => e; end'
  end

  before do
    Mutant::Random.stub(:hex_string => 'random')
  end

  pending do
    it_should_behave_like 'a mutator'
  end
end
