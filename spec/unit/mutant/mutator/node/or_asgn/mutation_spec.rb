# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::OpAsgn, 'or_asgn' do
  let(:random_fixnum) { 5        }
  let(:random_string) { 'random' }

  let(:source)  { 'a ||= 1' }

  let(:mutations) do
    mutations = []
    mutations << 'srandom ||= 1'
    mutations << 'a ||= nil'
    mutations << 'a ||= 0'
    mutations << 'a ||= -1'
    mutations << 'a ||= 2'
    mutations << 'a ||= 5'
    mutations << 'nil'
  end

  before do
    Mutant::Random.stub(fixnum: random_fixnum, hex_string: random_string)
  end

  it_should_behave_like 'a mutator'
end
