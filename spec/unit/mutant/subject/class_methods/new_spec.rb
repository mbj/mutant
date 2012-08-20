require 'spec_helper'

describe Mutant::Subject, '.new' do
  subject { object.new(matcher, context, ast) }

  let(:object) { described_class }

  let(:matcher) { mock('Matcher') }
  let(:context) { mock('Context') }
  let(:ast)     { mock('AST')     }

  it { should be_frozen }
end
