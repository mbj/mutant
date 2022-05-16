# frozen_string_literal: true

RSpec.describe Mutant::AST::Structure::Node do
  describe '.fixed' do
    def apply
      described_class.fixed(children)
    end

    context 'on empty children' do
      let(:children) { [] }

      it 'returns empty array' do
        expect(apply).to eql([])
      end
    end

    context 'on one child' do
      let(:children) { [[described_class::Fixed::Attribute, :child_name]] }

      it 'returns empty array' do
        expect(apply).to eql(
          [
            described_class::Fixed::Attribute.new(index: 0, name: :child_name)
          ]
        )
      end
    end

    context 'on two children' do
      let(:children) do
        [
          [described_class::Fixed::Attribute, :child_name_a],
          [described_class::Fixed::Descendant, :child_name_b]
        ]
      end

      it 'returns empty array' do
        expect(apply).to eql(
          [
            described_class::Fixed::Attribute.new(index: 0, name: :child_name_a),
            described_class::Fixed::Descendant.new(index: 1, name: :child_name_b)
          ]
        )
      end
    end
  end

  let(:test_attribute) do
    described_class::Fixed::Attribute.new(
      index: 0,
      name:  :test_attribute
    )
  end

  let(:test_descendant) do
    described_class::Fixed::Descendant.new(
      index: 1,
      name:  :test_descendant
    )
  end

  let(:instance) do
    described_class.new(
      fixed:    [test_attribute, test_descendant],
      variable: nil,
      type:     :test_type
    )
  end

  describe '#attribute' do
    def apply
      instance.attribute(name)
    end

    context 'on existing attribute' do
      let(:name) { :test_attribute }

      it 'returns expected attribute' do
        expect(apply).to be(test_attribute)
      end
    end

    context 'on name of descendant' do
      let(:name) { :test_descendant }

      it 'returns expected attribute' do
        expect { apply }.to raise_error(
          RuntimeError,
          'Node test_type does not have fixed attribute test_descendant'
        )
      end
    end

    context 'on non existing attribute' do
      let(:name) { :not_existing }

      it 'returns expected attribute' do
        expect { apply }.to raise_error(
          RuntimeError,
          'Node test_type does not have fixed attribute not_existing'
        )
      end
    end
  end

  describe '#descendant' do
    def apply
      instance.descendant(name)
    end

    context 'on existing descendant' do
      let(:name) { :test_descendant }

      it 'returns expected descendant' do
        expect(apply).to be(test_descendant)
      end
    end

    context 'on name of attribute' do
      let(:name) { :test_attribute }

      it 'returns expected descendant' do
        expect { apply }.to raise_error(
          RuntimeError,
          'Node test_type does not have fixed descendant test_attribute'
        )
      end
    end

    context 'on non existing attribute' do
      let(:name) { :not_existing }

      it 'returns expected attribute' do
        expect { apply }.to raise_error(
          RuntimeError,
          'Node test_type does not have fixed descendant not_existing'
        )
      end
    end
  end

  describe '#each_descendant' do
    let(:yields) { [] }

    let(:node) do
      s(:test_type, :test_value, s(:int, 1))
    end

    def apply
      instance.each_descendant(node, &yields.method(:<<))
    end

    context 'without individual fixed descendants' do
      let(:instance) { Mutant::AST::Structure.for(:int) }

      let(:node) { s(:int, 1) }

      it 'returns self' do
        expect(apply).to be(instance)
      end

      it 'yields empty descendants' do
        apply

        expect(yields).to eql([])
      end
    end

    context 'with individual fixed descendants' do
      it 'returns self' do
        expect(apply).to be(instance)
      end

      it 'yields the descendants' do
        apply

        expect(yields).to eql([s(:int, 1)])
      end
    end

    context 'with variable descendants' do
      let(:instance) { Mutant::AST::Structure.for(:send) }

      let(:node) { s(:send, nil, :foo, s(:int, 2)) }

      it 'returns self' do
        expect(apply).to be(instance)
      end

      it 'yields the variable descendants' do
        apply

        expect(yields).to eql([s(:int, 2)])
      end
    end

    context 'with variable descendants, that have nil members' do
      let(:instance) { Mutant::AST::Structure.for(:case) }

      let(:node) do
        s(:case, s(:int, 1), s(:when, s(:int, 2), nil), nil)
      end

      it 'returns self' do
        expect(apply).to be(instance)
      end

      it 'yields the variable descendants' do
        apply

        expect(yields).to eql(
          [
            s(:int, 1),
            s(:when, s(:int, 2), nil)
          ]
        )
      end
    end

    context 'with variable descendants, that are not nodes' do
      let(:instance) { Mutant::AST::Structure.for(:regopt) }

      let(:node) do
        s(:regopt, :i, :m)
      end

      it 'returns self' do
        expect(apply).to be(instance)
      end

      it 'yields the variable descendants' do
        apply

        expect(yields).to eql([])
      end
    end
  end

  describe '#each_descendant_deep' do
    let(:yields) { [] }

    let(:node) do
      s(:test_type, :test_value, s(:send, s(:int, 1), :to_s, *arguments))
    end

    def apply
      instance.each_descendant_deep(node, &yields.method(:<<))
    end

    context 'without variable descendants' do
      let(:arguments) { [] }

      it 'returns self' do
        expect(apply).to be(instance)
      end

      it 'yields descendants' do
        apply

        expect(yields).to eql([s(:send, s(:int, 1), :to_s), s(:int, 1)])
      end
    end

    context 'with variable descendants' do
      let(:arguments) { [s(:int, 2)] }

      it 'returns self' do
        expect(apply).to be(instance)
      end

      it 'yields descendants' do
        apply

        expect(yields).to eql(
          [
            s(:send, s(:int, 1), :to_s, s(:int, 2)),
            s(:int, 1),
            s(:int, 2)
          ]
        )
      end
    end
  end

  describe '#each_node' do
    let(:yields) { [] }

    let(:node) do
      s(:test_type, :test_value, s(:send, s(:int, 1), :to_s, *arguments))
    end

    def apply
      instance.each_node(node, &yields.method(:<<))
    end

    context 'without variable descendants' do
      let(:arguments) { [] }

      it 'returns self' do
        expect(apply).to be(instance)
      end

      it 'yields descendants' do
        apply

        expect(yields).to eql([node, s(:send, s(:int, 1), :to_s), s(:int, 1)])
      end
    end

    context 'with variable descendants' do
      let(:arguments) { [s(:int, 2)] }

      it 'returns self' do
        expect(apply).to be(instance)
      end

      it 'yields descendants' do
        apply

        expect(yields).to eql(
          [
            node,
            s(:send, s(:int, 1), :to_s, s(:int, 2)),
            s(:int, 1),
            s(:int, 2)
          ]
        )
      end
    end
  end
end
