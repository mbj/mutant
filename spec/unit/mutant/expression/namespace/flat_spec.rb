require 'spec_helper'

describe Mutant::Expression::Namespace::Exact do

  let(:object) { described_class.parse(input) }
  let(:env)    { Fixtures::TEST_ENV           }
  let(:input)  { 'TestApp::Literal'           }

  describe '#matcher' do
    subject { object.matcher(env) }

    it { should eql(Mutant::Matcher::Scope.new(env, TestApp::Literal, object)) }
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
