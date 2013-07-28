require 'spec_helper'

describe Mutant::Mutator::Node::While do

  context 'with more than one statement' do
    let(:source) { 'while true; foo; bar; end' }

    let(:mutations) do
      mutations = []
      mutations << 'while true; bar; end'
      mutations << 'while true; foo; end'
      mutations << 'while true; end'
      mutations << 'while false; foo; bar; end'
      mutations << 'while nil;   foo; bar; end'
    end

    it_should_behave_like 'a mutator'
  end
end
