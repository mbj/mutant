RSpec.describe Mutant::Subject do
  let(:class_under_test) do
    Class.new(described_class) do
      def expression
        Mutant::Expression.parse('SubjectA')
      end

      def match_expressions
        [expression] << Mutant::Expression.parse('SubjectB')
      end
    end
  end

  let(:object) { class_under_test.new(config, context, node) }

  let(:config) { Mutant::Config::DEFAULT }

  let(:node) do
    Parser::CurrentRuby.parse(<<-RUBY)
      def foo
      end
    RUBY
  end

  let(:location) do
    double('Location', expression: expression)
  end

  let(:expression) do
    double('Expression', line: 'source_line')
  end

  let(:context) do
    double(
      'Context',
      source_path: 'source_path',
      source_line: 'source_line'
    )
  end

  describe '#identification' do
    subject { object.identification }

    it { should eql('SubjectA:source_path:1') }
  end

  describe '#source_line' do
    subject { object.source_line }

    it { should be(1) }
  end

  describe '#source_lines' do
    subject { object.source_lines }

    it { should eql(1..2) }
  end

  describe '#prepare' do
    subject { object.prepare }

    it_should_behave_like 'a command method'
  end

  describe '#tests' do
    let(:config)      { Mutant::Config::DEFAULT.update(integration: integration)         }
    let(:integration) { double('Integration', all_tests: all_tests)                      }
    let(:test_a)      { double('test', expression: Mutant::Expression.parse('SubjectA')) }
    let(:test_b)      { double('test', expression: Mutant::Expression.parse('SubjectB')) }
    let(:test_c)      { double('test', expression: Mutant::Expression.parse('SubjectC')) }

    subject { object.tests }

    context 'without available tests' do
      let(:all_tests) { [] }

      it { should eql([]) }

      it_should_behave_like 'an idempotent method'
    end

    context 'without qualifying tests' do
      let(:all_tests) { [test_c] }

      it { should eql([]) }

      it_should_behave_like 'an idempotent method'
    end

    context 'with qualifying tests for first match expression' do
      let(:all_tests) { [test_a] }

      it { should eql([test_a]) }

      it_should_behave_like 'an idempotent method'
    end

    context 'with qualifying tests for second match expression' do
      let(:all_tests) { [test_b] }

      it { should eql([test_b]) }

      it_should_behave_like 'an idempotent method'
    end

    context 'with qualifying tests for the first and second match expression' do
      let(:all_tests) { [test_a, test_b] }

      it { should eql([test_a]) }

      it_should_behave_like 'an idempotent method'
    end
  end

  describe '#node' do
    subject { object.node }

    it { should be(node) }

    it_should_behave_like 'an idempotent method'
  end

  describe '#mutations' do
    subject { object.mutations }

    before do
      expect(Mutant::Mutator).to receive(:each).with(node).and_yield(mutation_a).and_yield(mutation_b)
    end

    let(:mutation_a) { double('Mutation A') }
    let(:mutation_b) { double('Mutation B') }

    it 'generates neutral and evil mutations' do
      should eql([
        Mutant::Mutation::Neutral.new(object, node),
        Mutant::Mutation::Evil.new(object, mutation_a),
        Mutant::Mutation::Evil.new(object, mutation_b)
      ])
    end
  end
end
