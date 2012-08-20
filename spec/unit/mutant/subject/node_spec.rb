require 'spec_helper'

describe Mutant::Subject, '#node' do
  subject { object.node }
  let(:object)  { described_class.new(matcher, context, node) }
  let(:matcher) { mock('Matcher') }
  let(:node)    { mock('Node')    }
  let(:context) { mock('Context') }

  it { should be(node) }

  it_should_behave_like 'an idempotent method'
end
