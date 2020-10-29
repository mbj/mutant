# frozen_string_literal: true

RSpec.describe Mutant::Selector::Expression do
  describe '#call' do
    let(:object) { described_class.new(integration) }

    let(:context)  { instance_double(Mutant::Context)   }
    let(:node)     { instance_double(Parser::AST::Node) }
    let(:test_a)   { mk_test('SubjectA')                }
    let(:test_b)   { mk_test('SubjectB')                }
    let(:test_c)   { mk_test('SubjectC')                }
    let(:warnings) { instance_double(Mutant::Warnings)  }

    let(:integration) do
      instance_double(
        Mutant::Integration,
        all_tests: all_tests
      )
    end

    let(:mutation_subject) do
      subject_class.new(
        context:  context,
        node:     node,
        warnings: warnings
      )
    end

    def mk_test(expression)
      instance_double(
        Mutant::Test,
        expressions: [parse_expression(expression)]
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
      let(:all_tests) { [] }

      it { should eql([]) }
    end

    context 'without qualifying tests' do
      let(:all_tests) { [test_c] }

      it { should eql([]) }
    end

    context 'with qualifying tests for first match expression' do
      let(:all_tests) { [test_a] }

      it { should eql([test_a]) }
    end

    context 'with qualifying tests for second match expression' do
      let(:all_tests) { [test_b] }

      it { should eql([test_b]) }
    end

    context 'with qualifying tests for the first and second match expression' do
      let(:all_tests) { [test_a, test_b] }

      it { should eql([test_a]) }
    end
  end
end
