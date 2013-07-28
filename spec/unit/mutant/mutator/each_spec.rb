# encoding: utf-8

# This file is the sandbox for new mutations.
# Once finished mutation test will be moved to class specfic
# file.

require 'spec_helper'

describe Mutant::Mutator, '.each' do

  pending 'interpolated string literal (DynamicString)' do
    let(:source) { '"foo#{1}bar"' }

    let(:random_string) { 'this-is-random' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
    end

    before do
      Mutant::Random.stub(:hex_string => random_string)
    end

    it_should_behave_like 'a mutator'
  end
end
