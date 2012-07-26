require 'spec_helper'

describe Mutant::Mutatee,'#context' do
  subject { object.context }

  let(:object)  { described_class.new(context,ast) }
  let(:ast)     { mock('AST') }
  let(:context) { mock('Context') }

  it { should be(context) }

  it_should_behave_like 'an idempotent method'
end
