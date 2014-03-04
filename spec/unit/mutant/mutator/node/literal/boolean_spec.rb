# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Literal, 'boolean' do
  context 'true literal' do
    let(:source) { 'true' }

    let(:mutations) do
      %w(nil false)
    end

    it_should_behave_like 'a mutator'
  end

  context 'false literal' do
    let(:source) { 'false' }

    let(:mutations) do
      %w(nil true)
    end

    it_should_behave_like 'a mutator'
  end
end
