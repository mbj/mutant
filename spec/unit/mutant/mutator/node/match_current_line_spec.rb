# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Generic, 'match_current_line' do
  before do
    pending
  end

  let(:source) { 'true if //' }

  let(:mutations) do
    mutations = []
    mutations << 'false if //'
    mutations << 'nil if //'
    mutations << 'true if true'
    mutations << 'true if false'
    mutations << 'true if nil'
    mutations << s(:if, s(:send, s(:match_current_line, s(:regexp, s(:regopt))), :!), s(:true), nil)
    mutations << 'true if /a\A/'
    mutations << 'nil'
  end

  it_should_behave_like 'a mutator'
end
