# frozen_string_literal: true

RSpec.describe Mutant::Expression::Namespace::Exact do
  let(:object) { parse_expression(input) }
  let(:input)  { 'TestApp::Literal'      }

  describe '#matcher' do
    subject { object.matcher }

    context 'when constant does not exist' do
      let(:input) { 'TestApp::DoesNotExist' }

      it { should eql(Mutant::Matcher::Null.new) }
    end

    context 'when constant exists' do
      it { should eql(Mutant::Matcher::Scope.new(TestApp::Literal)) }
    end
  end

  describe '#match_length' do
    subject { object.match_length(other) }

    context 'when other is an equivalent expression' do
      let(:other) { parse_expression(object.syntax) }

      it { should be(object.syntax.length) }
    end

    context 'when other is an unequivalent expression' do
      let(:other) { parse_expression('Foo*') }

      it { should be(0) }
    end
  end
end
