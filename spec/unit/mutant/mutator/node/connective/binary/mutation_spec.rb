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

      mutations << 'false and false'
      mutations << 'true and true'

      mutations << 'nil and false'
      mutations << 'true and nil'
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

      mutations << 'false or false'
      mutations << 'true or true'

      mutations << 'nil or false'
      mutations << 'true or nil'
    end

    it_should_behave_like 'a mutator'
  end
end
