RSpec.describe Mutant::Selector::Expression do
  describe '#call' do
    let(:object) { described_class.new(integration) }

    let(:subject_class) do
      parse = method(:parse_expression)

      Class.new(Mutant::Subject) do
        define_method(:expression) do
          parse.('SubjectA')
        end

        define_method(:match_expressions) do
          [expression] << parse.('SubjectB')
        end
      end
    end

    let(:mutation_subject) { subject_class.new(context, node)                           }
    let(:context)          { double('Context')                                          }
    let(:node)             { double('Node')                                             }
    let(:config)           { Mutant::Config::DEFAULT.with(integration: integration)     }
    let(:integration)      { double('Integration', all_tests: all_tests)                }
    let(:test_a)           { double('test a', expression: parse_expression('SubjectA')) }
    let(:test_b)           { double('test b', expression: parse_expression('SubjectB')) }
    let(:test_c)           { double('test c', expression: parse_expression('SubjectC')) }

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
