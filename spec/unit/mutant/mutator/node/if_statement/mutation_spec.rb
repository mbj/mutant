require 'spec_helper'

describe Mutant::Mutator, 'if statement' do
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
  end

  it_should_behave_like 'a mutator'
end
