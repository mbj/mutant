# encoding: utf-8

require 'spec_helper'

describe Mutant::CLI::Classifier, '.run' do
  subject { described_class.run(cache, input) }

  let(:cache) { double('Cache') }

  this_spec = 'Mutant::CLI::Classifier.build'

  shared_examples_for this_spec do
    it 'shoud return expected instance' do
      should eql(expected_matcher)
    end

    let(:expected_class) { Mutant::CLI::Classifier::Method }
  end

  context 'with explicit toplevel scope' do

    let(:input) { '::TestApp::Literal#string' }

    let(:expected_matcher) do
      Mutant::Matcher::Method::Instance.new(cache, TestApp::Literal, TestApp::Literal.instance_method(:string))
    end

    include_examples this_spec
  end

  context 'with instance method notation' do

    let(:input) { 'TestApp::Literal#string' }

    let(:expected_matcher) do
      Mutant::Matcher::Method::Instance.new(cache, TestApp::Literal, TestApp::Literal.instance_method(:string))
    end

    include_examples this_spec
  end

  context 'with singleton method notation' do
    let(:input) { 'TestApp::Literal.string' }

    let(:expected_matcher) do
      Mutant::Matcher::Method::Singleton.new(cache, TestApp::Literal, TestApp::Literal.method(:string))
    end

    include_examples this_spec
  end

  context 'with invalid notation' do
    let(:input) { '::' }

    it 'should return nil' do
      expect { subject }.to raise_error(Mutant::CLI::Error, "No matcher handles: #{input.inspect}")
    end
  end
end
