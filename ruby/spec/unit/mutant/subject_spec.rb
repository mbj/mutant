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

  let(:object) do
    class_under_test.new(
      config:  Mutant::Subject::Config::DEFAULT,
      context:,
      node:
    )
  end

  let(:node) do
    Unparser.parse(<<-'RUBY')
      def foo
      end
    RUBY
  end

  let(:context) do
    instance_double(
      Mutant::Context,
      source_path: 'source_path'
    )
  end

  before do
    allow(context).to receive(:root) do |node|
      s(:module, s(:const, nil, :Root), node)
    end
  end

  describe '#identification' do
    subject { object.identification }

    it { is_expected.to eql('SubjectA:source_path:1') }
  end

  describe '#source_line' do
    subject { object.source_line }

    it { is_expected.to be(1) }
  end

  describe '#source_lines' do
    subject { object.source_lines }

    it { is_expected.to eql(1..2) }
  end

  describe '#prepare' do
    subject { object.prepare }

    it_behaves_like 'a command method'
  end

  describe '#post_insert' do
    subject { object.post_insert }

    it_behaves_like 'a command method'
  end

  describe '#node' do
    subject { object.node }

    it { is_expected.to be(node) }

    it_behaves_like 'an idempotent method'
  end

  describe '#mutations' do
    subject { object.mutations }

    before do
      expect(Mutant::Mutator::Node)
        .to receive(:mutate)
        .with(
          config: Mutant::Mutation::Config::DEFAULT,
          node:
        )
        .and_return([mutation_a, mutation_b])
    end

    let(:mutation_a) { s(:true)  }
    let(:mutation_b) { s(:false) }

    it 'generates neutral and evil mutations' do
      is_expected.to eql([
        Mutant::Mutation::Neutral.from_node(subject: object, node:),
        Mutant::Mutation::Evil.from_node(subject: object, node: mutation_a),
        Mutant::Mutation::Evil.from_node(subject: object, node: mutation_b)
      ].map(&:from_right))
    end
  end

  describe '#inline_disabled?' do
    subject { object.inline_disabled? }

    context 'on default config' do
      it { is_expected.to be(false) }
    end

    context 'when config has an inline disable' do
      let(:object) do
        super().with(config: super().config.with(inline_disable: true))
      end

      it { is_expected.to be(true) }
    end
  end
end
