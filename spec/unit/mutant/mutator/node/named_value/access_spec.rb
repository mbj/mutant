# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::NamedValue::Access, 'mutations' do

  context 'global variable' do
    let(:source) { '$a = nil; $a' }

    let(:mutations) do
      mutants = []
      mutants << '$a = nil; nil'
      mutants << '$a = nil'
      mutants << '$a'
      mutants << '$a__mutant__ = nil; $a'
      mutants << 'nil; $a'
    end

    it_should_behave_like 'a mutator'
  end

  context 'class variable' do
    let(:source) { '@@a = nil; @@a' }

    let(:mutations) do
      mutants = []
      mutants << '@@a = nil; nil'
      mutants << '@@a = nil'
      mutants << '@@a'
      mutants << '@@a__mutant__ = nil; @@a'
      mutants << 'nil; @@a'
    end
  end

  context 'instance variable' do
    let(:source) { '@a = nil; @a' }

    let(:mutations) do
      mutants = []
      mutants << '@a = nil; nil'
      mutants << '@a = nil'
      mutants << '@a'
      mutants << '@a__mutant__ = nil; @a'
      mutants << 'nil; @a'
    end

    it_should_behave_like 'a mutator'
  end

  context 'local variable' do
    let(:source) { 'a = nil; a' }

    let(:mutations) do
      mutants = []
      mutants << 'a = nil; nil'
      mutants << 'a = nil'
      # TODO: fix invalid AST
      #   These ASTs are not valid and should NOT be emitted
      #   Mutations of lvarasgn need to be special cased to avoid this.
      mutants << s(:begin, s(:lvasgn, :a__mutant__, s(:nil)), s(:lvar, :a))
      mutants << s(:begin, s(:nil), s(:lvar, :a))
      mutants << s(:lvar, :a)
    end

    it_should_behave_like 'a mutator'
  end

  context 'self' do
    let(:source) { 'self' }

    let(:mutations) do
      mutants = []
      mutants << 'nil'
    end

    it_should_behave_like 'a mutator'
  end
end
