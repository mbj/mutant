RSpec.describe Mutant::Matcher::Compiler do
  let(:object) { described_class }

  let(:env) { Fixtures::TEST_ENV }

  let(:expression_a) { parse_expression('Foo*') }
  let(:expression_b) { parse_expression('Bar*') }

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

      context 'and a subject ignore' do
        let(:attributes) do
          {
            match_expressions:  [expression_a],
            ignore_expressions: [expression_b]
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
    end

    context 'on config with multiple match expressions' do
      let(:attributes) do
        { match_expressions: [expression_a, expression_b] }
      end

      let(:expected_positive_matcher) { Mutant::Matcher::Chain.new([matcher_a, matcher_b]) }
    end
  end
end
