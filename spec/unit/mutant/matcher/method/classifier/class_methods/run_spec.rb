require 'spec_helper'

describe Mutant::Matcher::Method::Classifier, '.run' do
  subject { described_class.run(input) }


  context 'with instance method notation' do
    let(:input)          { 'TestApp::Literal#string' }
    let(:expected_class) { Mutant::Matcher::Method::Instance }

    it_should_behave_like 'a method filter parse result'
  end

  context 'with singleton method notation' do
    let(:input)          { 'TestApp::Literal.string' }
    let(:expected_class) { Mutant::Matcher::Method::Singleton }

    it_should_behave_like 'a method filter parse result'
  end

  context 'with invalid notation' do
    let(:input) { 'Foo' }

    it 'should raise error' do
      expect { subject }.to raise_error(ArgumentError, "Cannot determine subject from #{input.inspect}")
    end
  end
end
