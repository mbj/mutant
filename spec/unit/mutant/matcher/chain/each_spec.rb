require 'spec_helper'

describe Mutant::Matcher::Chain, '#each' do
  subject { object.each { |entry| yields << entry } }

  let(:object) { described_class.new(matchers) }

  let(:matchers) { [matcher_a, matcher_b] }

  let(:matcher_a) { mock('Matcher A') }
  let(:matcher_b) { mock('Matcher B') }

  let(:subject_a) { mock('Subject A') }
  let(:subject_b) { mock('Subject B') }
  
  before do
    matcher_a.stub(:each).and_yield(subject_a).and_return(matcher_a)
    matcher_b.stub(:each).and_yield(subject_b).and_return(matcher_b)
  end

  it_should_behave_like 'an #each method'

  let(:yields) { [] }

  it 'should yield subjects' do
    expect { subject }.to change { yields }.from([]).to([subject_a, subject_b])
  end
end
