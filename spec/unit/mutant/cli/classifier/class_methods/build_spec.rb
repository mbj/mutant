# encoding: utf-8

require 'spec_helper'

describe Mutant::CLI::Classifier, '.build' do
  subject { described_class.build(cache, input) }

  let(:cache) { double('Cache') }

  this_spec = 'Mutant::CLI::Classifier.build'

  shared_examples_for this_spec do
    it 'shoud return expected instance' do
      regexp = expected_class::REGEXP
      should eql(expected_class.new(cache, regexp.match(input)))
    end

    let(:expected_class) { Mutant::CLI::Classifier::Method }
  end

  context 'with explicit toplevel scope' do

    let(:input) { '::TestApp::Literal#string' }

    it_should_behave_like this_spec
  end

  context 'with instance method notation' do

    let(:input) { 'TestApp::Literal#string' }

    it_should_behave_like this_spec
  end

  context 'with singleton method notation' do
    let(:input) { 'TestApp::Literal.string' }

    it_should_behave_like this_spec
  end

  context 'with invalid notation' do
    let(:input) { '::' }

    it 'should return nil' do
      expect { subject }.to raise_error(Mutant::CLI::Error, "No matcher handles: #{input.inspect}")
    end
  end
end
