# frozen_string_literal: true

RSpec.describe Mutant::Expression::Namespace::Recursive do
  let(:object) { parse_expression(input) }
  let(:input)  { 'TestApp::Literal*'     }

  describe '#matcher' do
    subject { object.matcher }

    it { should eql(Mutant::Matcher::Namespace.new(object)) }
  end

  describe '#syntax' do
    subject { object.syntax }

    it { should eql(input) }
  end

  describe '#match_length' do
    subject { object.match_length(other) }

    context 'when other is an equivalent expression' do
      let(:other) { parse_expression(object.syntax) }

      it { should be(object.syntax.length) }
    end

    context 'when other expression describes a shorter prefix' do
      let(:other) { parse_expression('TestApp') }

      it { should be(0) }
    end

    context 'when other expression describes adjacent namespace' do
      let(:other) { parse_expression('TestApp::LiteralFoo') }

      it { should be(0) }
    end

    context 'when other expression describes root namespace' do
      let(:other) { parse_expression('TestApp::Literal') }

      it { should be(16) }
    end

    context 'when other expression describes a longer prefix' do
      context 'on constants' do
        let(:other) { parse_expression('TestApp::Literal::Deep') }

        it { should be(input[0..-2].length) }
      end

      context 'on singleton method' do
        let(:other) { parse_expression('TestApp::Literal.foo') }

        it { should be(input[0..-2].length) }
      end

      context 'on instance method' do
        let(:other) { parse_expression('TestApp::Literal#foo') }

        it { should be(input[0..-2].length) }
      end
    end
  end
end
