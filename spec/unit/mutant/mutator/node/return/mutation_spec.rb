require 'spec_helper'

describe Mutant::Mutator, 'return' do

  context 'return without value' do
    let(:source) { 'return' }

    let(:mutations) { ['nil'] }

    it_should_behave_like 'a mutator'
  end

  context 'return with value' do
    let(:source) { 'return nil' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << 'return ::Object.new'
    end

    it_should_behave_like 'a mutator'
  end

end
