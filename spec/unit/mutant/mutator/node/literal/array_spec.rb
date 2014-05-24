# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Literal, 'array' do

  context 'on one item' do
    let(:source) { '[true]' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << 'true'
      mutations << '[false]'
      mutations << '[nil]'
      mutations << '[]'
    end

    it_should_behave_like 'a mutator'
  end

  context 'on arrays with more than one item' do
    let(:source) { '[true, false]' }

    let(:mutations) do
      mutations = []

      # Literal replaced with nil
      mutations << 'nil'

      # Mutation of each element in array
      mutations << '[nil, false]'
      mutations << '[false, false]'
      mutations << '[true, nil]'
      mutations << '[true, true]'

      # Remove each element of array once
      mutations << '[true]'
      mutations << '[false]'

      # Empty array
      mutations << '[]'
    end

    it_should_behave_like 'a mutator'
  end
end
