# This file is the sandbox for new mutations.
# Once finished mutation test will be moved to class specfic
# file.

require 'spec_helper'

describe Mutant::Mutator, '.each' do
  let(:random_string) { 'bar' }

  pending 'interpolated string literal (DynamicString)' do
    let(:source) { '"foo#{1}bar"' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
    end

    before do
      Mutant::Random.stub(:hex_string => random_string)
    end

    it_should_behave_like 'a mutation enumerator method'
  end
end
