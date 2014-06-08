# encoding: utf-8

require 'spec_helper'

describe Mutant::Expression::Namespace::Exact do

  let(:object)            { described_class.parse(input) }
  let(:cache)             { Mutant::Cache.new            }
  let(:input)             { 'TestApp::Literal'           }

  describe '#matcher' do
    subject { object.matcher(cache) }

    it { should eql(Mutant::Matcher::Namespace::Scope.new(cache, TestApp::Literal)) }
  end

  describe '#match_length' do
    subject { object.match_length(other) }

    context 'when other is an equivalent expression' do
      let(:other) { described_class.parse(object.syntax) }

      it { should be(object.syntax.length) }
    end

    context 'when other is an unequivalent expression' do
      let(:other) { described_class.parse('Foo*') }

      it { should be(0) }
    end
  end
end
