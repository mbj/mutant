require 'spec_helper'

describe Mutant::Mutator::Literal, 'array' do
  let(:source) { '[true, false]' }

  let(:mutations) do
    mutations = []

    # Literal replaced with nil
    mutations << [:nil]

    # Mutation of each element in array
    mutations << '[nil, false]'
    mutations << '[false, false]'
    mutations << '[true, nil]'
    mutations << '[true, true]'

    # Remove each element of array once
    mutations << '[true]'
    mutations << '[false]'

    # Empty array
    mutations << '[]'

    # Extra element
    mutations << '[true, false, nil]'
  end

  it_should_behave_like 'a mutation enumerator method'
end
