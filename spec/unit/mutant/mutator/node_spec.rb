# frozen_string_literal: true

aggregate = Hash.new { |hash, key| hash[key] = [] }

Mutant::Meta::Example::ALL
  .each_with_object(aggregate) do |example, agg|
    example.types.each do |type|
      agg[Mutant::Mutator::Node::REGISTRY.lookup(type)] << example
    end
  end

aggregate.each do |mutator, examples|
  RSpec.describe mutator do
    it 'generates expected mutations' do
      examples.each do |example|
        verification = example.verification
        fail verification.error_report unless verification.success?
      end
    end
  end
end

RSpec.describe Mutant::Mutator::Node do
  describe '.handle' do
    subject do
      Class.new(described_class) do
        const_set(:REGISTRY, Mutant::Registry.new(->(_) { fail }))

        handle :send

        def dispatch
          emit(parent)
        end
      end
    end

    it 'should register mutator' do
      expect(subject.mutate(node: s(:send), parent: s(:parent))).to eql([s(:parent)].to_set)
    end
  end

  describe 'internal DSL' do
    let(:klass) do
      Class.new(described_class) do
        children(:left, :right)

        def dispatch
          left
          emit_left(s(:int, 1))
          emit_left_mutations
          emit_right_mutations do |node|
            node.eql?(s(:nil))
          end
        end
      end
    end

    def apply
      klass.call(input: s(:and, s(:true), s(:true)), parent: nil)
    end

    specify do
      expect(apply).to eql(
        [
          s(:and, s(:false), s(:true)),
          s(:and, s(:int, 1), s(:true))
        ].to_set
      )
    end
  end
end
