# frozen_string_literal: true

RSpec.describe Mutant::Meta::Example do
  let(:object) do
    described_class.new(
      expected:        mutation_nodes,
      location:,
      lvars:           [],
      node:,
      operators:       Mutant::Mutation::Operators::Full.new,
      original_source: 'true',
      types:           [node.type]
    )
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
      Mutant::Mutation::Evil.build(subject: object, node:).from_right
    end
  end

  it 'does not define any repeated examples' do
    source_counts = described_class::ALL.each_with_object(Hash.new(0)) do |example, counts|
      counts["#{example.location.path}:#{example.original_source}:#{example.operators.class.name}"] += 1
    end

    expect(source_counts.select { |_source, count| count > 1 }.keys).to eql([])
  end

  describe '#original_source_generated' do
    subject { object.original_source_generated }

    it { should eql('true') }
  end

  describe '#verification' do
    subject { object.verification }

    it { should eql(Mutant::Meta::Example::Verification.new(example: object, mutations:)) }
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

    it { should eql(Mutant::Context.new(constant_scope:, scope:, source_path: location.path)) }
  end

  describe '#identification' do
    subject { object.identification }

    it { should eql('<location>') }
  end
end
