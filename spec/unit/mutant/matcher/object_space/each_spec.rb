require 'spec_helper'

describe Mutant::Matcher::ObjectSpace, '#each' do
  subject { object.each { |item| yields << item } }

  let(:yields) { []                                               }
  let(:object) { described_class.new(/\ATestApp::Literal(\z|::)/) }

  before do
    Mutant::Matcher::Method::Singleton.stub(:each => [matcher_a])
    Mutant::Matcher::Method::Instance.stub(:each => [matcher_b])
  end


  let(:matcher_a) { mock('Matcher A') }
  let(:matcher_b) { mock('Matcher B') }

  let(:subject_a) { mock('Subject A') }
  let(:subject_b) { mock('Subject B') }
  
  before do
    matcher_a.stub(:each).and_yield(subject_a).and_return(matcher_a)
    matcher_b.stub(:each).and_yield(subject_b).and_return(matcher_b)
  end

  it_should_behave_like 'an #each method'


  it 'should yield subjects' do
    expect { subject }.to change { yields }.from([]).to([subject_a, subject_b])
  end
end
