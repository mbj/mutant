RSpec.describe Mutant::Matcher::Compiler, '#call' do
  let(:object)         { described_class                  }
  let(:env)            { Fixtures::TEST_ENV               }
  let(:matcher_config) { Mutant::Matcher::Config::DEFAULT }
  let(:expression_a)   { parse_expression('Foo*')         }
  let(:expression_b)   { parse_expression('Bar*')         }
  let(:matcher_a)      { expression_a.matcher             }
  let(:matcher_b)      { expression_b.matcher             }

  let(:expected_matcher) do
    Mutant::Matcher::Filter.new(
      expected_positive_matcher,
      expected_predicate
    )
  end

  let(:expected_predicate) do
    Morpher.compile(s(:and, s(:negate, s(:or)), s(:and)))
  end

  subject { object.call(matcher_config.with(attributes)) }

  context 'on empty config' do
    let(:attributes) { {} }

    let(:expected_positive_matcher) { Mutant::Matcher::Chain.new([]) }

    it { should eql(expected_matcher) }
  end

  context 'on config with match expression' do
    let(:expected_predicate) do
      Morpher::Evaluator::Predicate::Boolean::And.new(
        [
          Morpher::Evaluator::Predicate::Negation.new(
            Morpher::Evaluator::Predicate::Boolean::Or.new(ignore_expression_predicates)
          ),
          Morpher::Evaluator::Predicate::Boolean::And.new(subject_filter_predicates)
        ]
      )
    end

    let(:expected_positive_matcher)    { Mutant::Matcher::Chain.new([matcher_a]) }
    let(:attributes)                   { { match_expressions: [expression_a] }   }
    let(:ignore_expression_predicates) { []                                      }
    let(:subject_filter_predicates)    { []                                      }

    context 'and no other constraints' do
      it { should eql(expected_matcher) }
    end

    context 'and ignore expressions' do
      let(:attributes) do
        super().merge(ignore_expressions: [expression_b])
      end

      let(:ignore_expression_predicates) do
        [Mutant::Matcher::Compiler::SubjectPrefix.new(expression_b)]
      end

      it { should eql(expected_matcher) }
    end

    context 'and subject filters' do
      let(:filter) { double('filter') }

      let(:attributes) do
        super().merge(subject_filters: [filter])
      end

      let(:subject_filter_predicates) do
        [filter]
      end

      it { should eql(expected_matcher) }
    end
  end
end
