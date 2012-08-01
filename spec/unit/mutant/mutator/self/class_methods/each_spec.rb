require 'spec_helper'

describe Mutant::Mutator::Self, '.each' do
  let(:source) { 'self' }

  it_should_behave_like 'a noop mutation enumerator method'
end
