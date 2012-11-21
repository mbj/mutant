require 'spec_helper'

describe Mutant::Matcher::ObjectSpace, '#each' do
  before do
    pending "defunct"
  end
  subject { object.each { |item| yields << item } }

  let(:yields) { []                                               }
  let(:object) { described_class.new(/\ATestApp::Literal(\z|::)/) }

  before do
    Mutant::Matcher::Method::Singleton.stub(:each).and_yield(matcher_a)
    Mutant::Matcher::Method::Instance.stub(:each).and_yield(matcher_b)
    matcher_a.stub(:each).and_yield(subject_a)
    matcher_b.stub(:each).and_yield(subject_b)
  end


  let(:matcher_a) { mock('Matcher A') }
  let(:matcher_b) { mock('Matcher B') }

  let(:subject_a) { mock('Subject A') }
  let(:subject_b) { mock('Subject B') }
  
  it_should_behave_like 'an #each method'

  it 'should yield subjects' do
    expect { subject }.to change { yields }.from([]).to([subject_a, subject_b])
  end
end
