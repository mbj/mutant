# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Generic, 'defined?' do
  let(:source) { 'defined?(foo)' }

  let(:mutations) do
    mutations = []
    mutations << 'defined?(nil)'
  end

  it_should_behave_like 'a mutator'
end
