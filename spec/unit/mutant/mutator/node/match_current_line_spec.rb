# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Generic, 'match_current_line' do
  let(:source) { 'true if /foo/' }

  let(:mutations) do
    mutations = []
    mutations << 'false if /foo/'
    mutations << 'true if //'
    mutations << 'nil if /foo/'
    mutations << 'true if true'
    mutations << 'true if false'
    mutations << 'true if nil'
    mutations << 'true if /a\A/'
    mutations << 'nil'
  end

  it_should_behave_like 'a mutator'
end
