require 'spec_helper'

describe Mutant::Mutator, 'block' do

  context 'with more than one statement' do
    let(:source) { "true\nfalse" }

    let(:mutations) do
      mutations = []

      # Mutation of each statement in block
      mutations << "true\ntrue"
      mutations << "false\nfalse"
      mutations << "nil\nfalse"
      mutations << "true\nnil"

      # Remove statement in block
      mutations << s(:begin, s(:true))
      mutations << s(:begin, s(:false))
      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'with one statement' do
    let(:source) { 'true' }

    let(:mutations) do
      mutations = []
      mutations << s(:false)
      mutations << s(:nil)
    end

    it_should_behave_like 'a mutator'
  end
end
