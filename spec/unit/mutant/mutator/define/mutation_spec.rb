require 'spec_helper'

describe Mutant::Mutator, 'define' do

  context 'with no arguments' do
    let(:source) { 'def foo; self.bar; self.baz; end' }

    let(:mutations) do
      mutations = []

      # Mutation of each statement in block
      mutations << 'def foo; bar; self.baz; end'
      mutations << 'def foo; self.bar; baz; end'

      # Remove statement in block
      mutations << 'def foo; self.baz; end'
      mutations << 'def foo; self.bar; end'
    end

    it_should_behave_like 'a mutator'
  end
end
