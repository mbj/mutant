require 'spec_helper'

describe Mutant::Matcher, '.parse' do
  subject { object.parse(input) }

  let(:input) { mock('Input') }
  let(:object) { described_class }

  it { should be(nil) }

  it_should_behave_like 'an idempotent method'
end
