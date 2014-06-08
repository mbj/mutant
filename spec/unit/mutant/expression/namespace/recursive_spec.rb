# encoding: utf-8

require 'spec_helper'

describe Mutant::Expression::Namespace::Recursive do

  let(:object) { described_class.parse(input) }
  let(:cache)  { Mutant::Cache.new            }
  let(:input)  { 'TestApp::Literal*'          }

  describe '#matcher' do
    subject { object.matcher(cache) }
    it { should eql(Mutant::Matcher::Namespace.new(cache, 'TestApp::Literal')) }
  end

  describe '#match_length' do
    subject { object.match_length(other) }

    context 'when other is an equivalent expression' do
      let(:other) { described_class.parse(object.syntax) }

      it { should be(0) }
    end

    context 'when other expression describes a shorter prefix' do
      let(:other) { described_class.parse('TestApp') }

      it { should be(0) }
    end

    context 'when other expression describes adjacent namespace' do
      let(:other) { described_class.parse('TestApp::LiteralFoo') }

      it { should be(0) }
    end

    context 'when other expression describes a longer prefix' do
      let(:other) { described_class.parse('TestApp::Literal::Deep') }

      it { should be(input[0..-2].length) }
    end
  end
end
