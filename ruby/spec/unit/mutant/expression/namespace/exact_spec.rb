# frozen_string_literal: true

RSpec.describe Mutant::Expression::Namespace::Exact do
  let(:object) { parse_expression(input) }
  let(:input)  { 'TestApp::Literal'      }

  describe '#matcher' do
    subject { object.matcher(env: instance_double(Mutant::Env)) }

    let(:scope) do
      Mutant::Scope.new(
        expression: Mutant::Expression::Namespace::Exact.new(scope_name: 'TestApp::Literal'),
        raw:        TestApp::Literal
      )
    end

    context 'when constant does not exist' do
      let(:input) { 'TestApp::DoesNotExist' }

      it { is_expected.to eql(Mutant::Matcher::Null.new) }
    end

    context 'when constant exists' do
      it { is_expected.to eql(Mutant::Matcher::Scope.new(scope:)) }
    end
  end

  describe '#syntax' do
    subject { object.syntax }

    it { is_expected.to eql(input) }
  end

  describe '#match_length' do
    subject { object.match_length(other) }

    context 'when other is an equivalent expression' do
      let(:other) { parse_expression(object.syntax) }

      it { is_expected.to be(object.syntax.length) }
    end

    context 'when other is an unequivalent expression' do
      let(:other) { parse_expression('Foo*') }

      it { is_expected.to be(0) }
    end
  end
end
