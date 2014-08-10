require 'spec_helper'

describe Mutant::Expression::Method do

  let(:object)           { described_class.parse(input) }
  let(:env)              { Fixtures::TEST_ENV           }
  let(:instance_method)  { 'TestApp::Literal#string'    }
  let(:singleton_method) { 'TestApp::Literal.string'    }

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
    subject { object.matcher(env) }

    context 'with an instance method' do
      let(:input) { instance_method }

      it 'returns correct matcher' do
        should eql(Mutant::Matcher::Method::Instance.new(
          env,
          TestApp::Literal, TestApp::Literal.instance_method(:string)
        ))
      end
    end

    context 'with a singleton method' do
      let(:input) { singleton_method }

      it { should eql(Mutant::Matcher::Method::Singleton.new(env, TestApp::Literal, TestApp::Literal.method(:string))) }
    end
  end
end
