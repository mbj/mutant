require 'spec_helper'

describe Mutant::Mutator::Block, '.each' do
  # Two send operations
  let(:source) { "foo\nbar" }

  let(:mutations) do
    mutations = []

    # Mutation of each statement in block
    mutations << "foo\nself.bar"
    mutations << "self.foo\nbar"

   ## Remove statement in block
    mutations << [:block, 'foo'.to_sexp]
    mutations << [:block, 'bar'.to_sexp]
  end

  it_should_behave_like 'a mutation enumerator method'
end
