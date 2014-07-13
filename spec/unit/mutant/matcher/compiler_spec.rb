require 'spec_helper'

describe Mutant::Matcher::Compiler do
  let(:object) { described_class }

  let(:env) { Fixtures::TEST_ENV }

  let(:expression_a) { Mutant::Expression.parse('Foo*') }
  let(:expression_b) { Mutant::Expression.parse('Bar*') }

  let(:matcher_a) { expression_a.matcher(env) }
  let(:matcher_b) { expression_b.matcher(env) }

  let(:expected_matcher) do
    Mutant::Matcher::Filter.new(expected_positive_matcher, expected_predicate)
  end

  let(:expected_predicate) do
    Morpher.compile(s(:true))
  end

  describe '.call' do
    subject { object.call(env, matcher_config.update(attributes)) }

    let(:matcher_config) { Mutant::Matcher::Config::DEFAULT }

    context 'on empty config' do
      let(:attributes) { {} }

      let(:expected_positive_matcher) { Mutant::Matcher::Chain.new([]) }

      it { should eql(expected_matcher) }
    end

    context 'on config with match expression' do
      context 'and no filter' do
        let(:attributes) do
          { match_expressions: [expression_a] }
        end

        let(:expected_positive_matcher) { Mutant::Matcher::Chain.new([matcher_a]) }

        it { should eql(expected_matcher) }
      end

      context 'and a subject filter' do
        let(:attributes) do
          {
            match_expressions: [expression_a],
            subject_ignores:   [expression_b]
          }
        end

        let(:expected_positive_matcher) { Mutant::Matcher::Chain.new([matcher_a]) }

        let(:expected_predicate) do
          Morpher::Evaluator::Predicate::Negation.new(
            Morpher::Evaluator::Predicate::Boolean::Or.new([
              described_class::SubjectPrefix.new(expression_b)
            ])
          )
        end

        it { should eql(expected_matcher) }
      end

      context 'and an attribute filter' do
        let(:attributes) do
          {
            match_expressions: [expression_a],
            subject_selects:   [[:code, 'foo']]
          }
        end

        let(:expected_positive_matcher) { Mutant::Matcher::Chain.new([matcher_a]) }

        let(:expected_predicate) do
          Morpher::Evaluator::Predicate::Boolean::Or.new([
            Morpher.compile(s(:eql, s(:attribute, :code), s(:static, 'foo')))
          ])
        end

        it { should eql(expected_matcher) }
      end

      context 'and subject and attribute filter' do
        let(:attributes) do
          {
            match_expressions: [expression_a],
            subject_ignores:   [expression_b],
            subject_selects:   [[:code, 'foo']]
          }
        end

        let(:expected_positive_matcher) { Mutant::Matcher::Chain.new([matcher_a]) }

        let(:expected_predicate) do
          Morpher::Evaluator::Predicate::Boolean::And.new([
            Morpher::Evaluator::Predicate::Boolean::Or.new([
              Morpher.compile(s(:eql, s(:attribute, :code), s(:static, 'foo')))
            ]),
            Morpher::Evaluator::Predicate::Negation.new(
              Morpher::Evaluator::Predicate::Boolean::Or.new([
                described_class::SubjectPrefix.new(expression_b)
              ])
            )
          ])
        end

        it { should eql(expected_matcher) }
      end
    end

    context 'on config with multiple match expressions' do
      let(:attributes) do
        { match_expressions: [expression_a, expression_b] }
      end

      let(:expected_positive_matcher) { Mutant::Matcher::Chain.new([matcher_a, matcher_b]) }
    end
  end
end
