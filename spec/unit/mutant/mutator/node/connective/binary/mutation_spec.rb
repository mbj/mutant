require 'spec_helper'

describe Mutant::Mutator::Node::Connective::Binary, 'mutations' do
  context 'and' do
    let(:source) { 'true and false' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << 'true'
      mutations << 'false'

      mutations << 'true or false'

      mutations << 'not true and false'
      mutations << 'true and not false'
    end

    it_should_behave_like 'a mutator'
  end

  context 'or' do
    let(:source) { 'true or false' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << 'true'
      mutations << 'false'

      mutations << 'true and false'

      mutations << 'not true or false'
      mutations << 'true or not false'
    end

    it_should_behave_like 'a mutator'
  end
end
