require 'spec_helper'

describe Mutant::Mutator::Literal::Boolean,'.each' do
  context 'true literal' do
    let(:source) { 'true' }

    let(:mutations) do
      %w(nil false)
    end

    it_should_behave_like 'a mutation enumerator method'
  end

  context 'false literal' do
    let(:source) { 'false' }

    let(:mutations) do
      %w(nil true)
    end

    it_should_behave_like 'a mutation enumerator method'
  end
end
