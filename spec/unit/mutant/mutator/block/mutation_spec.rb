require 'spec_helper'

describe Mutant::Mutator, 'block' do
  # Two send operations
  let(:source) { "self.foo\nself.bar" }

  let(:mutations) do
    mutations = []

    # Mutation of each statement in block
    mutations << "foo\nself.bar"
    mutations << "self.foo\nbar"

   ## Remove statement in block
    mutations << [:block, 'self.foo'.to_sexp]
    mutations << [:block, 'self.bar'.to_sexp]
  end

  it_should_behave_like 'a mutation enumerator method'
end
