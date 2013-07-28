require 'spec_helper'

describe Mutant::Mutator::Node::Generic, 'defined?' do
  let(:source)    { 'defined?(foo)' }
  let(:mutations) { []              }

  it_should_behave_like 'a mutator'
end
