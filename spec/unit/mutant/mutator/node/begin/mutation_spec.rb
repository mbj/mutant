require 'spec_helper'

describe Mutant::Mutator, 'begin' do

  # This mutation and only this mutation can result in
  # and empty emit that is parsed into nil, unparser cannot
  # handle this so we guard this here!
  def generate(node)
    return '' if node.nil?
    super
  end

  let(:source) { "true\nfalse" }

  let(:mutations) do
    mutations = []

    # Mutation of each statement in block
    mutations << "true\ntrue"
    mutations << "false\nfalse"
    mutations << "nil\nfalse"
    mutations << "true\nnil"

    # Remove statement in block
    mutations << 'true'
    mutations << 'false'
  end

  it_should_behave_like 'a mutator'
end
