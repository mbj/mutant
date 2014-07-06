require 'spec_helper'

describe Mutant::Expression do
  let(:object) { described_class }

  describe '.try_parse' do
    subject { object.try_parse(input) }

    context 'on nonsense' do
      let(:input) { 'foo bar' }

      it { should be(nil) }
    end

    context 'on a valid expression' do
      let(:input) { 'Foo' }

      it { should eql(Mutant::Expression::Namespace::Exact.new('Foo')) }
    end

    context 'on ambigious expression' do
      class ExpressionA < Mutant::Expression
        register(/\Atest-syntax\z/)
      end

      class ExpressionB < Mutant::Expression
        register(/^test-syntax$/)
      end

      let(:input) { 'test-syntax' }

      it 'raises an exception' do
        expect { subject }.to raise_error(Mutant::Expression::AmbigousExpressionError, 'Ambigous expression: "test-syntax"')
      end
    end
  end

  describe '.parse' do
    subject { object.parse(input) }

    context 'on nonsense' do
      let(:input) { 'foo bar' }

      it 'raises an exception' do
        expect { subject }.to raise_error(Mutant::Expression::InvalidExpressionError, 'Expression: "foo bar" is not valid')
      end
    end

    context 'on a valid expression' do
      let(:input) { 'Foo' }

      it { should eql(Mutant::Expression::Namespace::Exact.new('Foo')) }
    end
  end
end
