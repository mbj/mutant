require 'spec_helper'

describe Mutant::Matcher::ObjectSpace, '.parse' do
  subject { object.parse(input) }

  let(:object) { described_class }

  let(:matcher) { mock('Matcher') }

  context 'with valid notation' do
    let(:input) { '::TestApp::Literal' }

    it 'should return matcher' do
      described_class.should_receive(:new).with(%r(\ATestApp::Literal(\z|::))).and_return(matcher)
      should be(matcher)
    end
  end

  context 'with invalid notation' do
    let(:input) { 'TestApp' }

    it { should be(nil) }
  end
end
