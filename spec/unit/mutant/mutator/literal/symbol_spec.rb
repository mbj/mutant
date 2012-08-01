require 'spec_helper'

describe Mutant::Mutator::Literal, 'symbol' do
  let(:random_string) { 'bar' }

  let(:source) { ':foo' }

  let(:mutations) do
    %w(nil) << ":#{random_string}"
  end

  before do
    Mutant::Random.stub(:hex_string => random_string)
  end

  it_should_behave_like 'a mutator'
end
