require 'spec_helper'

describe Mutant::Mutator, 'block' do

  context 'with more than one statement' do
    let(:source) { "self.foo\nself.bar" }

    let(:mutations) do
      mutations = []

      # Mutation of each statement in block
      mutations << "foo\nself.bar".to_ast
      mutations << "self.foo\nbar".to_ast

      # Remove statement in block
      mutations << Rubinius::AST::Block.new(1, ['self.foo'.to_ast])
      mutations << Rubinius::AST::Block.new(1, ['self.bar'.to_ast])
      mutations << Rubinius::AST::Block.new(1, ['nil'.to_ast])
    end

    it_should_behave_like 'a mutator'
  end



  context 'with one statement' do
    let(:node) { Rubinius::AST::Block.new(1, ['self.foo'.to_ast]) }

    let(:mutations) do
      mutations = []
      mutations << Rubinius::AST::Block.new(1, ['foo'.to_ast])
      mutations << Rubinius::AST::Block.new(1, ['nil'.to_ast])
    end

    it_should_behave_like 'a mutator'
  end
end
