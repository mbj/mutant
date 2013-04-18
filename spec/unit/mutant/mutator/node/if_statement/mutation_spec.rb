require 'spec_helper'

describe Mutant::Mutator, 'if statement' do

  context 'if with two branches' do
    let(:source) { 'if self.condition; true; else false; end' }

    let(:mutations) do
      mutants = []

      # mutations of condition
      mutants << 'if condition; true; else false; end'

      mutants << 'if !self.condition; true; else false; end'

      # Deleted else branch
      mutants << 'if self.condition; true end'

      # Deleted if branch with promoting else branch to if branch
      mutants << 'if self.condition; false end'

      # mutations of body
      mutants << 'if self.condition; false; else false; end'
      mutants << 'if self.condition; nil;   else false; end'

      # mutations of else body
      mutants << 'if self.condition; true;  else true;  end'
      mutants << 'if self.condition; true;  else nil;   end'

      # mutation of condition to always be true
      mutants << 'if true; true; else false; end'

      # mutation of condition to always be false
      mutants << 'if false; true; else false; end'
    end

    it_should_behave_like 'a mutator'
  end

  context 'unless with one branch' do
    let(:source) { 'unless condition; true; end' }

    let(:mutations) do
      mutants = []
      mutants << 'unless !condition; true; end'
      mutants << 'if condition; true; end'
      mutants << 'unless condition; false; end'
      mutants << 'unless condition; nil; end'
      mutants << 'unless true; true; end'
      mutants << 'unless false; true; end'
    end

    it_should_behave_like 'a mutator'
  end

  context 'if with one branch' do
    let(:source) { 'if condition; true; end' }

    let(:mutations) do
      mutants = []
      mutants << 'if !condition; true; end'
      mutants << 'if condition; false; end'
      mutants << 'if condition; nil; end'
      mutants << 'if true; true; end'
      mutants << 'if false; true; end'
    end

    it_should_behave_like 'a mutator'
  end
end
