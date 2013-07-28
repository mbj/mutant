require 'spec_helper'

describe Mutant::Mutator, 'masgn' do
  let(:source)    { 'a, b = c, d' }
  let(:mutations) { []            }

  it_should_behave_like 'a mutator'
end
