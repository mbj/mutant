# frozen_string_literal: true

aggregate = Hash.new { |hash, key| hash[key] = [] }

Mutant::Meta::Example::ALL
  .each_with_object(aggregate) do |example, agg|
    example.types.each do |type|
      agg[Mutant::Mutator::REGISTRY.lookup(type)] << example
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
  describe 'internal DSL' do
    let(:klass) do
      Class.new(described_class) do
        children(:left, :right)

        def dispatch
          left
          emit_left(s(:nil))
          emit_right_mutations do |node|
            node.eql?(s(:nil))
          end
        end
      end
    end

    def apply
      klass.call(s(:and, s(:true), s(:true)))
    end

    specify do
      expect(apply).to eql(
        [
          s(:and, s(:nil), s(:true)),
          s(:and, s(:true), s(:nil))
        ].to_set
      )
    end
  end
end
