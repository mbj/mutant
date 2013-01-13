require 'spec_helper'

describe Mutant::Subject, '#node' do
  subject { object.node }

  let(:class_under_test) do
    Class.new(described_class)
  end

  let(:object)  { class_under_test.new(context, node) }
  let(:node)    { mock('Node')    }
  let(:context) { mock('Context') }

  it { should be(node) }

  it_should_behave_like 'an idempotent method'
end
