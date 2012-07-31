require 'spec_helper'

describe Mutant::Matcher::Method, '#context' do
  subject { object.context }

  let(:object)  { described_class::Singleton.new('SampleSubjects::ExampleModule', 'foo') }
  let(:context) { mock('Context')                                                       }

  before do
    Mutant::Context::Constant.stub(:build => context)
  end

  it { should be(context); }

  it 'should build context with subject' do
    Mutant::Context::Constant.should_receive(:build).with(::SampleSubjects::ExampleModule).and_return(context)
    should be(context)
  end

  it_should_behave_like 'an idempotent method'
end
