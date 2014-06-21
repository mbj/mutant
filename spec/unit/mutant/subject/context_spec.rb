require 'spec_helper'

describe Mutant::Subject, '#context' do
  subject { object.context }

  let(:class_under_test) do
    Class.new(described_class)
  end

  let(:object)  { class_under_test.new(context, node) }
  let(:node)    { double('Node')                      }
  let(:context) { double('Context')                   }

  it { should be(context) }

  it_should_behave_like 'an idempotent method'
end
