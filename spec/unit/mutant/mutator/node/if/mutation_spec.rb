# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator, 'if' do
  before do
    Mutant::Random.stub(hex_string: 'random')
  end

  context 'with if and else branches' do
    let(:source) { 'if :condition; true; else false; end' }

    let(:mutations) do
      mutants = []

      # mutations of condition
      mutants << 'if :srandom;    true; else false; end'
      mutants << 'if !:condition; true; else false; end'
      mutants << 'if nil;         true; else false; end'
      mutants << 'if true;        true; else false; end'
      mutants << 'if false;       true; else false; end'

      # Deleted else branch
      mutants << 'if :condition; true end'

      # Deleted if branch resuting in unless rendering
      mutants << 'unless :condition; false; end'

      # Deleted if branch with promoting else branch to if branch
      mutants << 'if :condition; false end'

      # mutations of if body
      mutants << 'if :condition; false; else false; end'
      mutants << 'if :condition; nil;   else false; end'

      # mutations of else body
      mutants << 'if :condition; true;  else true;  end'
      mutants << 'if :condition; true;  else nil;   end'

      mutants << 'nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'if with one branch' do
    let(:source) { 'if condition; true; end' }

    let(:mutations) do
      mutants = []
      mutants << 'if !condition; true;  end'
      mutants << 'if condition;  false; end'
      mutants << 'if condition;  nil;   end'
      mutants << 'if true;       true;  end'
      mutants << 'if false;      true;  end'
      mutants << 'if nil;        true;  end'
      mutants << 'nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'unless with one branch' do
    let(:source) { 'unless :condition; true; end' }

    let(:mutations) do
      mutants = []
      mutants << 'unless !:condition; true;  end'
      mutants << 'unless :srandom;    true;  end'
      mutants << 'unless nil;         true;  end'
      mutants << 'unless :condition;  false; end'
      mutants << 'unless :condition;  nil;   end'
      mutants << 'unless true;        true;  end'
      mutants << 'unless false;       true;  end'
      mutants << 'if     :condition;  true;  end'
      mutants << 'nil'
    end

    it_should_behave_like 'a mutator'
  end
end
