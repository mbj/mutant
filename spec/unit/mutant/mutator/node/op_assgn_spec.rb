# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Generic, 'op_asgn' do
  let(:random_fixnum) { 5 }

  let(:source) { '@a.b += 1' }

  let(:mutations) do
    mutations = []
    mutations << '@a.b += -1'
    mutations << '@a.b += 2'
    mutations << '@a.b += 0'
    mutations << '@a.b += nil'
    mutations << '@a.b += 5'
    mutations << 'nil.b += 1'
    mutations << 'nil'
    # TODO:
    #   This should not get emitted as invalid AST with valid unparsed source
    mutations << s(:op_asgn, s(:ivar, :@a), :+, s(:int, 1))
  end

  before do
    Mutant::Random.stub(fixnum: random_fixnum)
  end

  it_should_behave_like 'a mutator'
end
