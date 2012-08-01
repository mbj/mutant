require 'spec_helper'

describe Mutant::Mutator::Literal, 'hash' do
  let(:source) { '{true => true, false => false}' }

  let(:mutations) do
    mutations = []

    # Literal replaced with nil
    mutations << [:nil]

    # Mutation of each key and value in hash
    mutations << [:hash, [:false ], [:true ], [:false], [:false]]
    mutations << [:hash, [:nil   ], [:true ], [:false], [:false]]
    mutations << [:hash, [:true  ], [:false], [:false], [:false]]
    mutations << [:hash, [:true  ], [:nil  ], [:false], [:false]]
    mutations << [:hash, [:true  ], [:true ], [:true ], [:false]]
    mutations << [:hash, [:true  ], [:true ], [:nil  ], [:false]]
    mutations << [:hash, [:true  ], [:true ], [:false], [:true ]]
    mutations << [:hash, [:true  ], [:true ], [:false], [:nil  ]]

    # Remove each key once
    mutations << [:hash, [:true  ], [:true ]]
    mutations << [:hash, [:false ], [:false ]]

    # Empty hash
    mutations << [:hash]

    # Extra element
    mutations << [:hash, [:true  ], [:true ], [:false], [:false ], [:nil], [:nil] ]
  end

  it_should_behave_like 'a mutation enumerator method'
end
