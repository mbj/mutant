# frozen_string_literal: true

RSpec.describe Mutant::Meta::Example do
  let(:object) do
    described_class.new(
      expected:        mutation_nodes,
      location:,
      lvars:           [],
      node:,
      operators:,
      original_source: 'true',
      types:           [node.type]
    )
  end

  let(:operators) do
    Mutant::Mutation::Operators::Full.new
  end

  let(:location) do
    instance_double(
      Thread::Backtrace::Location,
      path: 'foo/bar.rb',
      to_s: '<location>'
    )
  end

  let(:node)           { s(:true)     }
  let(:mutation_nodes) { [s(:false)]  }

  let(:mutations) do
    mutation_nodes.map do |node|
      Mutant::Mutation::Evil.from_node(subject: object, node:)
    end
  end

  it 'does not define any repeated examples' do
    source_counts = described_class::ALL.each_with_object(Hash.new(0)) do |example, counts|
      counts["#{example.location.path}:#{example.original_source}:#{example.operators.class.name}"] += 1
    end

    expect(source_counts.select { |_source, count| count > 1 }.keys).to eql([])
  end

  describe '#source' do
    subject { object.source }

    it { is_expected.to eql('true') }
  end

  describe '#verification' do
    subject { object.verification }

    it { is_expected.to eql(Mutant::Meta::Example::Verification.from_mutations(example: object, mutations:)) }
  end

  let(:constant_scope) do
    Mutant::Context::ConstantScope::None.new
  end

  describe '#context' do
    subject { object.context }

    let(:scope) do
      Mutant::Scope.new(
        expression: Mutant::Expression::Namespace::Exact.new(scope_name: 'Object'),
        raw:        Object
      )
    end

    it { is_expected.to eql(Mutant::Context.new(constant_scope:, scope:, source_path: location.path)) }
  end

  describe '#identification' do
    subject { object.identification }

    it { is_expected.to eql('<location>') }
  end

  describe '#generated' do
    subject { object.generated }

    let(:node) { s(:send, s(:nil), :==, s(:nil)) }

    shared_examples 'expected mutations' do
      it 'generates expected mutations' do
        expect(subject).to eql(
          expected.map do |node|
            Mutant::Mutation::Evil.from_node(node:, subject: object)
          end
        )
      end
    end

    context 'on light operator set' do
      let(:expected)  { [s(:nil)]                              }
      let(:operators) { Mutant::Mutation::Operators::Light.new }

      include_examples 'expected mutations'
    end

    context 'on full operator set' do
      let(:operators) { Mutant::Mutation::Operators::Full.new }

      let(:expected) do
        [
          s(:nil),
          s(:send, s(:nil), :!=, s(:nil)),
          s(:send, s(:nil), :eql?, s(:nil)),
          s(:send, s(:nil), :equal?, s(:nil))
        ]
      end

      include_examples 'expected mutations'
    end
  end
end
