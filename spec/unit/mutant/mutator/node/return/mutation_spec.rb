require 'spec_helper'

describe Mutant::Mutator, 'return' do

  context 'return without value' do
    let(:source) { 'return' }

    let(:mutations) { ['nil'] }

    it_should_behave_like 'a mutator'
  end

  context 'return with value' do
    let(:source) { 'return foo' }

    let(:mutations) { ['foo'] }

    it_should_behave_like 'a mutator'
  end

end
