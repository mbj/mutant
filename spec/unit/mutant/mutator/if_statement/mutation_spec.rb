require 'spec_helper'

describe Mutant::Mutator, 'if statement' do
  let(:source) { 'if self.condition; true; else false; end' }

  let(:mutations) do
    mutants = []

    # mutations of condition
    mutants << 'if condition; true; else false; end'

    # Invert condition
    if Mutant::Helper.on_18?
      # Explicitly define ast as 18-mode does swap if and else on parsing when negation condition is 
      # present in condition.
      mutants << [:if, [:not, [:call, [:self], :condition, [:arglist]]], [:true], [:false]]
    else
      mutants << 'if !self.condition; true; else false; end'
    end

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
  end

  it_should_behave_like 'a mutator'
end
