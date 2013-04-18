require 'spec_helper'

describe Mutant::Mutator::Node::Literal, 'hash' do
  let(:source) { '{true => true, false => false}' }

  let(:mutations) do
    mutations = []

    # Literal replaced with nil
    mutations << 'nil'

    # Mutation of each key and value in hash
    mutations << '{ false => true  ,  false => false }'
    mutations << '{ nil   => true  ,  false => false }'
    mutations << '{ true  => false ,  false => false }'
    mutations << '{ true  => nil   ,  false => false }'
    mutations << '{ true  => true  ,  true  => false }'
    mutations << '{ true  => true  ,  nil   => false }'
    mutations << '{ true  => true  ,  false => true  }'
    mutations << '{ true  => true  ,  false => nil   }'

    # Remove each key once
    mutations << '{ true => true }'
    mutations << '{ false => false }'

    # Empty hash
    mutations << '{}'
  end

  it_should_behave_like 'a mutator'
end
