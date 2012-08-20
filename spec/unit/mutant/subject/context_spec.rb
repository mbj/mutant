require 'spec_helper'

describe Mutant::Subject, '#context' do
  subject { object.context }

  let(:object)  { described_class.new(matcher, context, ast) }
  let(:matcher) { mock('Matcher') }
  let(:ast)     { mock('AST')     }
  let(:context) { mock('Context') }

  it { should be(context) }

  it_should_behave_like 'an idempotent method'
end
