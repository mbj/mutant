# frozen_string_literal: true

RSpec.describe Mutant::AST::Pattern::Deep do
  let(:instance) do
    described_class.new(pattern: pattern)
  end

  let(:node) do
    s(:send, s(:send, s(:const, nil, :Foo), :bar), :baz)
  end

  describe '#match?' do
    def apply
      instance.match?(node)
    end

    context 'when pattern does not match any child' do
      let(:pattern) do
        Mutant::AST::Pattern::Node.new(type: :int)
      end

      it 'returns false' do
        expect(apply).to be(false)
      end
    end

    context 'when pattern does match a deep child' do
      let(:pattern) do
        Mutant::AST::Pattern::Node.new(type: :const)
      end

      it 'returns false' do
        expect(apply).to be(true)
      end
    end

    context 'when pattern does match a shallow child' do
      let(:pattern) do
        Mutant::AST::Pattern::Node.new(
          type:      :send,
          attribute: Mutant::AST::Pattern::Node::Attribute.new(
            name:  :selector,
            value: Mutant::AST::Pattern::Node::Attribute::Value::Single.new(value: :bar)
          )
        )
      end

      it 'returns false' do
        expect(apply).to be(true)
      end
    end

    context 'when pattern matches self' do
      let(:pattern) do
        Mutant::AST::Pattern::Node.new(
          type:      :send,
          attribute: Mutant::AST::Pattern::Node::Attribute.new(
            name:  :selector,
            value: Mutant::AST::Pattern::Node::Attribute::Value::Single.new(value: :baz)
          )
        )
      end

      it 'returns false' do
        expect(apply).to be(true)
      end
    end
  end
end
