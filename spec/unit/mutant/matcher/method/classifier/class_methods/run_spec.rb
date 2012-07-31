require 'spec_helper'

shared_examples_for 'a method filter parse result' do
  it { should be(response) }

  it 'should initialize method filter with correct arguments' do
    expected_class.should_receive(:new).with('Foo', :bar).and_return(response)
    subject
  end
end

describe Mutant::Matcher::Method::Classifier, '.run' do
  subject { described_class.run(input) }

  context 'with format' do
    before do
      expected_class.stub(:new => response)
    end

    let(:response) { mock('Response') }

    context 'in instance method notation' do
      let(:input)          { 'Foo#bar' }
      let(:expected_class) { Mutant::Matcher::Method::Instance }

      it_should_behave_like 'a method filter parse result'
    end

    context 'when input is in singleton method notation' do
      let(:input)          { 'Foo.bar' }
      let(:expected_class) { Mutant::Matcher::Method::Singleton }

      it_should_behave_like 'a method filter parse result'
    end
  end

  context 'when input is not in a valid format' do
    let(:input) { 'Foo' }

    it 'should raise error' do
      expect { subject }.to raise_error(ArgumentError, "Cannot determine subject from #{input.inspect}")
    end
  end
end
