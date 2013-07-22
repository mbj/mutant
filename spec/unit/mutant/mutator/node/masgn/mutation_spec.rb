require 'spec_helper'

describe Mutant::Mutator, 'masgn' do

  before do
    Mutant::Random.stub(:hex_string => 'random')
  end

  let(:source) { 'a, b = c, d' }

  let(:mutations) do
    mutants = []
  end

  it_should_behave_like 'a mutator'
end
