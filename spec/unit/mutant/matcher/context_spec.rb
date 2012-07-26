require 'spec_helper'

describe Mutant::Matcher,'#context' do
  subject { object.context }

  let(:object)        { described_class.new(constant_name) }
  let(:constant_name) { 'Foo'                              }
  let(:context)       { mock('Context')                    }

  before do
    Mutant::Context.stub(:build => context)
  end


  #it { should be(context) }

  #it_should_behave_like 'an idempotent method'
end
