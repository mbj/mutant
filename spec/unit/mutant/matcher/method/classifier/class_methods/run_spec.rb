require 'spec_helper'

describe Mutant::Matcher::Method::Classifier, '.run' do
  subject { described_class.run(input) }

  shared_examples_for 'Mutant::Matcher::Method::Classifier.run' do
    before do
      expected_class.stub(:new => response)
    end

    let(:response) { :Response }

    it { should be(response) }

    it 'should initialize method filter with correct arguments' do
      expected_class.should_receive(:new).with(TestApp::Literal, expected_method).and_return(response)
      subject
    end
  end

  context 'with explicit toplevel scope' do
    let(:input)           { '::TestApp::Literal#string' }
    let(:expected_class)  { Mutant::Matcher::Method::Instance }
    let(:expected_method) { TestApp::Literal.instance_method(:string) }

    it_should_behave_like 'Mutant::Matcher::Method::Classifier.run'
  end

  context 'with instance method notation' do
    let(:input)           { 'TestApp::Literal#string' }
    let(:expected_method) { TestApp::Literal.instance_method(:string) }
    let(:expected_class)  { Mutant::Matcher::Method::Instance }

    it_should_behave_like 'Mutant::Matcher::Method::Classifier.run'
  end

  context 'with singleton method notation' do
    let(:input)           { 'TestApp::Literal.string' }
    let(:expected_method) { TestApp::Literal.method(:string) }
    let(:expected_class)  { Mutant::Matcher::Method::Singleton }

    it_should_behave_like 'Mutant::Matcher::Method::Classifier.run'
  end

  context 'with invalid notation' do
    let(:input) { 'Foo' }

    it 'should return nil' do
      should be(nil)
    end
  end
end
