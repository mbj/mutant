require 'spec_helper'

describe Mutant::Matcher::Method, '.parse' do
  subject { described_class.parse(input) }

  let(:response) { mock('Response') }
  let(:input)    { mock('Input')    }

  let(:classifier) { described_class::Classifier }

  before do
    classifier.stub(:run => response)
  end

  it { should be(response) }

  it 'should call classifier' do
    classifier.should_receive(:run).with(input).and_return(response)
    subject
  end
end
