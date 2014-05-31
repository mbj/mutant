# encoding: utf-8

require 'spec_helper'

describe Mutant::Expression::Method do

  let(:object)           { described_class.parse(input) }
  let(:cache)            { Mutant::Cache.new            }
  let(:instance_method)  { '::TestApp::Literal#string'  }
  let(:singleton_method) { '::TestApp::Literal.string'  }

  describe '#match_length' do
    let(:input) { instance_method }

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

  describe '#matcher' do
    subject { object.matcher(cache) }

    context 'with an instance method' do
      let(:input) { instance_method }

      it { should eql(Mutant::Matcher::Method::Instance.new(cache, TestApp::Literal, TestApp::Literal.instance_method(:string))) }
    end

    context 'with a singleton method' do
      let(:input) { singleton_method }

      it { should eql(Mutant::Matcher::Method::Singleton.new(cache, TestApp::Literal, TestApp::Literal.method(:string))) }
    end
  end
end
