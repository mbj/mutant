require 'spec_helper'

describe Mutant::Mutator::Node::Literal, 'regex' do

  let(:source) { '/foo/' }

  let(:mutations) do
    mutations = []
    mutations << 'nil'
    mutations << '//' # match all
    mutations << '/a\A/' # match nothing
  end

  it_should_behave_like 'a mutator'
end
