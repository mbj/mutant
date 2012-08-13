require 'spec_helper'

describe Mutant::Mutator, 'block' do

  context 'with more than one statement' do
    let(:source) { "self.foo\nself.bar" }

    let(:mutations) do
      mutations = []

      # Mutation of each statement in block
      mutations << "foo\nself.bar"
      mutations << "self.foo\nbar"

     ## Remove statement in block
      mutations << [:block, 'self.foo'.to_sexp]
      mutations << [:block, 'self.bar'.to_sexp]
    end

    it_should_behave_like 'a mutator'
  end


  context 'with one statement' do
    let(:node) { Rubinius::AST::Block.new(1, ['self.foo'.to_ast]) }

    let(:mutations) do
      mutations = []
      mutations << [:block, 'foo'.to_sexp]
      # Empty blocks result in stack verification error
      mutations << [:block, 'nil'.to_sexp]
    end

    it_should_behave_like 'a mutator'
  end
end
