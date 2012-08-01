# This file is the sandbox for new mutations.
# Once finished mutation test will be moved to class specfic
# file.

require 'spec_helper'

describe Mutant::Mutator, '.each' do
  context 'case statements' do
    let(:source) { 'case self.condition; when true; true; when false; false; else raise; end' }

    let(:mutations) do
      mutations = []

      # Delete each when once
      mutations << 'case self.condition; when true; true; else raise; end'
      mutations << 'case self.condition; when false; false; else raise; end'

      # Mutate receiver
      mutations << 'case condition; when true; true; when false; false; else raise; end'

      # Remove else branch
      mutations << 'case self.condition; when true; true; when false; false; end'

      # Mutate when branch bodies
      mutations << 'case self.condition; when true; nil;   when false; false; else raise; end'
      mutations << 'case self.condition; when true; false; when false; false; else raise; end'
      mutations << 'case self.condition; when true; true;  when false; nil;   else raise; end'
      mutations << 'case self.condition; when true; true;  when false; true;  else raise; end'
    end

    it_should_behave_like 'a mutator'
  end

  pending 'interpolated string literal (DynamicString)' do
    let(:source) { '"foo#{1}bar"' }

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
