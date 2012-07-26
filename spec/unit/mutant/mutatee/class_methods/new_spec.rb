require 'spec_helper'

describe Mutant::Mutatee,'.new' do
  subject { object.new(context,ast) }

  let(:object) { described_class }

  let(:context) { mock('Context') }
  let(:ast)     { mock('AST')     }

  it { should be_frozen }
end
