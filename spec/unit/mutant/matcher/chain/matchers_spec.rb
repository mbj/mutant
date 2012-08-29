require 'spec_helper'

describe Mutant::Matcher::Chain, '#matchers' do
  subject { object.matchers }

  let(:object)   { described_class.new(matchers) }
  let(:matchers) { mock('Matchers')              } 

  it { should be(matchers) }

  it_should_behave_like 'an idempotent method'
end
