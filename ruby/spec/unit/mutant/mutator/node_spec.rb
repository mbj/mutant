# frozen_string_literal: true

aggregate = Hash.new { |hash, key| hash[key] = [] }

Mutant::Meta::Example::ALL
  .each_with_object(aggregate) do |example, agg|
    example.types.each do |type|
      agg[Mutant::Mutator::Node::REGISTRY.lookup(type)] << example
    end
  end

aggregate.each do |mutator, examples|
  RSpec.describe mutator, mutant_expression: 'Mutant::Mutator::Node*' do
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
      expect(
        subject.mutate(
          config: Mutant::Mutation::Config::DEFAULT,
          node:   s(:send),
          parent: s(:parent)
        )
      ).to eql([s(:parent)].to_set)
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
      klass.call(
        config: Mutant::Mutation::Config::DEFAULT,
        input:  s(:and, s(:true), s(:true)),
        parent: nil
      )
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

  describe '.mutate', mutant_expression: 'Mutant::Mutator::Node*' do
    def apply
      described_class.mutate(
        config:,
        node:
      )
    end

    let(:node) { s(:true) }

    let(:config) do
      Mutant::Mutation::Config::DEFAULT.with(
        ignore_patterns: [ignore_pattern]
      )
    end

    context 'ignore pattern matching node' do
      let(:ignore_pattern) { Mutant::AST::Pattern.parse('true').from_right }

      context 'on direct match' do
        it 'returns no mutations' do
          expect(apply).to eql(Set.new)
        end
      end

      context 'on begin match' do
        let(:node) do
          s(:begin, s(:true), s(:int, 1))
        end

        it 'returns expected mutations' do
          expect(apply).to eql(
            [
              s(:begin, s(:true), s(:nil)),
              s(:begin, s(:true), s(:int, 0)),
              s(:begin, s(:true), s(:int, 2))
            ].to_set
          )
        end
      end

      context 'on begin match' do
        let(:node) do
          s(:begin, s(:int, 1), s(:true))
        end

        it 'returns expected mutations' do
          expect(apply).to eql(
            [
              s(:begin, s(:nil), s(:true)),
              s(:begin, s(:int, 0), s(:true)),
              s(:begin, s(:int, 2), s(:true))
            ].to_set
          )
        end
      end

      context 'on indirect single child match' do
        let(:node) do
          s(:def, :foo, s(:args), s(:true))
        end

        context 'on match' do
          it 'returns no ignored mutations' do
            expect(apply).to eql(
              [
                s(:def, :foo, s(:args), s(:send, nil, :raise)),
                s(:def, :foo, s(:args), s(:zsuper))
              ].to_set
            )
          end
        end

        context 'on non match' do
          let(:node) do
            s(:def, :foo, s(:args), s(:send, nil, :bar))
          end

          it 'returns all mutations' do
            expect(apply).to eql(
              [
                s(:def, :foo, s(:args), nil),
                s(:def, :foo, s(:args), s(:nil)),
                s(:def, :foo, s(:args), s(:send, nil, :raise)),
                s(:def, :foo, s(:args), s(:zsuper))
              ].to_set
            )
          end
        end
      end

      context 'on indirect multiple child match' do
        let(:node) do
          s(:def, :foo, s(:args), s(:begin, s(:true), s(:false)))
        end

        it 'returns no ignored mutations' do
          expect(apply).to eql(
            [
              s(:def, :foo, s(:args), s(:send, nil, :raise)),
              s(:def, :foo, s(:args), s(:zsuper)),
              s(:def, :foo, s(:args), s(:begin, s(:true), s(:true)))
            ].to_set
          )
        end
      end
    end

    context 'ignore pattern not matching node' do
      let(:ignore_pattern) { Mutant::AST::Pattern.parse('false').from_right }

      it 'returns no mutations' do
        expect(apply).to eql([s(:false)].to_set)
      end
    end

  end
end
