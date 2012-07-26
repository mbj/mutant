require 'spec_helper'

describe Mutant::Mutatee,'#node' do
  subject { object.node }
  let(:object)  { described_class.new(context,node) }
  let(:node)    { mock('Node') }
  let(:context) { mock('Context') }

  it { should be(node) }

  it_should_behave_like 'an idempotent method'
end
