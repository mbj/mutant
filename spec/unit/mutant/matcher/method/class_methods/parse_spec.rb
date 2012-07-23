require 'spec_helper'

shared_examples_for 'a method filter parse result' do
  it { should be(response) }

  it 'should initialize method filter with correct arguments' do
    expected_class.should_receive(:new).with('Foo','bar').and_return(response)
    subject
  end
end

describe Mutant::Matcher::Method,'.parse' do
  subject { described_class.parse(input) }

  before do
    expected_class.stub(:new => response)
  end

  let(:response) { mock('Response') }

  context 'when input is in instance method format' do
    let(:input)          { 'Foo#bar' }
    let(:expected_class) { described_class::Instance }

    it_should_behave_like 'a method filter parse result'
  end

  context 'when input is in singleton method format' do
    let(:input)          { 'Foo.bar' }
    let(:expected_class) { described_class::Singleton }

    it_should_behave_like 'a method filter parse result'
  end
end
