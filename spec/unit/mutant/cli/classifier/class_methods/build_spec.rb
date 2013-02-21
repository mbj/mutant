require 'spec_helper'

describe Mutant::CLI::Classifier, '.build' do
  subject { described_class.build(input) }

  this_spec = 'Mutant::CLI::Classifier.build'

  shared_examples_for this_spec do
    it 'shoud return expected instance' do
      should eql(expected_class.new(expected_class::REGEXP.match(input)))
    end
  end

  context 'with explicit toplevel scope' do

    let(:input)           { '::TestApp::Literal#string' }
    let(:expected_class)  { Mutant::CLI::Classifier::Method }

    it_should_behave_like this_spec
  end

  context 'with instance method notation' do

    let(:input)           { 'TestApp::Literal#string' }
    let(:expected_class)  { Mutant::CLI::Classifier::Method }

    it_should_behave_like this_spec
  end

  context 'with singleton method notation' do
    let(:input)           { 'TestApp::Literal.string' }
    let(:expected_class)  { Mutant::CLI::Classifier::Method }

    it_should_behave_like this_spec
  end

  context 'with invalid notation' do
    let(:input) { '::' }

    it 'should return nil' do
      should be(nil)
    end
  end
end
