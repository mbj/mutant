RSpec.describe Mutant::Selector::Expression do
  describe '#call' do
    let(:object) { described_class.new(all_tests) }

    let(:subject_class) do
      Class.new(Mutant::Subject) do
        def expression
          Mutant::Expression.parse('SubjectA')
        end

        def match_expressions
          [expression] << Mutant::Expression.parse('SubjectB')
        end
      end
    end

    let(:mutation_subject) { subject_class.new(context, node)                                   }
    let(:context)          { double('Context')                                                  }
    let(:node)             { double('Node')                                                     }

    let(:config)           { Mutant::Config::DEFAULT.update(integration: integration)           }
    let(:integration)      { double('Integration', all_tests: all_tests)                        }

    let(:test_a)           { double('test a', expression: Mutant::Expression.parse('SubjectA')) }
    let(:test_b)           { double('test b', expression: Mutant::Expression.parse('SubjectB')) }
    let(:test_c)           { double('test c', expression: Mutant::Expression.parse('SubjectC')) }

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
