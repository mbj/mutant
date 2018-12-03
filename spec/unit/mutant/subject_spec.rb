# frozen_string_literal: true

RSpec.describe Mutant::Subject do
  let(:class_under_test) do
    Class.new(described_class) do
      def expression
        Mutant::Expression::Namespace::Exact.new(scope_name: 'SubjectA')
      end

      def match_expressions
        [
          expression,
          Mutant::Expression::Namespace::Exact.new(scope_name: 'SubjectB')
        ]
      end
    end
  end

  let(:object) { class_under_test.new(context, node) }

  let(:node) do
    Unparser.parse(<<-RUBY)
      def foo
      end
    RUBY
  end

  let(:context) do
    double(
      'Context',
      source_path: 'source_path'
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

  describe '#node' do
    subject { object.node }

    it { should be(node) }

    it_should_behave_like 'an idempotent method'
  end

  describe '#mutations' do
    subject { object.mutations }

    before do
      expect(Mutant::Mutator).to receive(:mutate).with(node).and_return([mutation_a, mutation_b])
    end

    let(:mutation_a) { instance_double(Parser::AST::Node, :mutation_a) }
    let(:mutation_b) { instance_double(Parser::AST::Node, :mutation_b) }

    it 'generates neutral and evil mutations' do
      should eql([
        Mutant::Mutation::Neutral.new(object, node),
        Mutant::Mutation::Evil.new(object, mutation_a),
        Mutant::Mutation::Evil.new(object, mutation_b)
      ])
    end
  end
end
