require 'spec_helper'

describe Mutant::Context::Constant, '#unqualified_name' do
  subject { object.unqualified_name }

  let(:object) { described_class.build(SampleSubjects::ExampleModule) }

  it 'should return wrapped constants unqualified name' do
    should eql('ExampleModule')
  end

  it_should_behave_like 'an idempotent method'
end
