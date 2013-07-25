require 'spec_helper'

describe Mutant::Mutator::Node::Literal, 'regex' do

  context 'literal' do
    let(:source) { '/foo/' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << '//' # match all
      mutations << '/a\A/' # match nothing
    end

    it_should_behave_like 'a mutator'
  end

  context 'interpolated' do
    let(:source) { '/#{foo.bar}n/' }

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << '//' # match all
      mutations << '/#{foo}n/' # match all
      mutations << '/a\A/' # match nothing
    end

    it_should_behave_like 'a mutator'
  end

end
