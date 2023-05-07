# frozen_string_literal: true

RSpec.describe Mutant::Selector::Expression do
  describe '#call' do
    let(:object) { described_class.new(integration: integration) }

    let(:context)  { instance_double(Mutant::Context)   }
    let(:node)     { instance_double(Parser::AST::Node) }

    let(:test_a)   { mk_test('SubjectC', 'SubjectA')    }
    let(:test_b)   { mk_test('SubjectB')                }
    let(:test_c)   { mk_test('SubjectC')                }

    let(:integration) do
      instance_double(
        Mutant::Integration,
        available_tests: available_tests
      )
    end

    let(:mutation_subject) do
      subject_class.new(
        config:  Mutant::Subject::Config::DEFAULT,
        context: context,
        node:    node
      )
    end

    def mk_test(*expressions)
      instance_double(
        Mutant::Test,
        expressions: expressions.map(&method(:parse_expression))
      )
    end

    let(:subject_class) do
      parse = method(:parse_expression)

      Class.new(Mutant::Subject) do
        define_method(:expression) do
          parse.call('SubjectA')
        end

        define_method(:match_expressions) do
          [expression] << parse.call('SubjectB')
        end
      end
    end

    subject { object.call(mutation_subject) }

    context 'without available tests' do
      let(:available_tests) { [] }

      it { should eql([]) }
    end

    context 'without qualifying tests' do
      let(:available_tests) { [test_c] }

      it { should eql([]) }
    end

    context 'with qualifying tests for first match expression' do
      let(:available_tests) { [test_a] }

      it { should eql([test_a]) }
    end

    context 'with qualifying tests for second match expression' do
      let(:available_tests) { [test_b] }

      it { should eql([test_b]) }
    end

    context 'with qualifying tests for the first and second match expression' do
      let(:available_tests) { [test_a, test_b] }

      it { should eql([test_a]) }
    end
  end
end
