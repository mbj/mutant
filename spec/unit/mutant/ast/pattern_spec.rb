# frozen_string_literal: true

RSpec.describe Mutant::AST::Pattern do
  describe '.parse' do
    def apply
      described_class.parse(string)
    end

    context 'empty string' do
      let(:string) { '' }

      it 'returns expected error' do
        expect(apply).to eql(left('Expected token of type: string, but got no token at all'))
      end
    end

    context 'invalid string token' do
      let(:string) { 'foo[' }

      it 'returns expected error' do
        expect(apply).to eql(left(<<~'MESSAGE'.strip))
          Invalid string token:
          foo[
          ^^^^
        MESSAGE
      end
    end

    context 'invalid node type' do
      let(:string) { 'foo' }

      it 'returns expected error' do
        expect(apply).to eql(left(<<~'MESSAGE'.strip))
          Expected valid node type got: foo
          foo
          ^^^
        MESSAGE
      end
    end

    context 'invalid node type, with extra token' do
      let(:string) { 'foo send' }

      it 'returns expected error' do
        expect(apply).to eql(left(<<~'MESSAGE'.strip))
          Expected valid node type got: foo
          foo send
          ^^^
        MESSAGE
      end
    end

    context 'premature end of token sequence' do
      let(:string) { 'send=' }

      it 'returns expected error' do
        expect(apply).to eql(left(<<~'MESSAGE'.strip))
          Unexpected token: eq
          send=
              ^
        MESSAGE
      end
    end

    context 'unexpected token' do
      let(:string) { 'send{=' }

      it 'returns expected error' do
        expect(apply).to eql(left(<<~'MESSAGE'.strip))
          Expected token type: string but got: eq
          send{=
               ^
        MESSAGE
      end
    end

    context 'invalid attribute name' do
      let(:string) { 'send{invalid=foo}' }

      it 'returns expected error' do
        expect(apply).to eql(left(<<~'MESSAGE'.strip))
          Node: send has no property named: invalid
          send{invalid=foo}
               ^^^^^^^
        MESSAGE
      end
    end

    context 'unexpected token alternative' do
      let(:string) { 'send{selector==' }

      it 'returns expected error' do
        expect(apply).to eql(left(<<~'MESSAGE'.strip))
          Expected one of: group_start,string but got: eq
          send{selector==
                        ^
        MESSAGE
      end
    end

    context 'valid single token' do
      let(:string) { 'send' }

      let(:expected_node) do
        Mutant::AST::Pattern::Node.new(type: :send)
      end

      it 'returns expected node' do
        expect(apply).to eql(right(expected_node))
      end
    end

    context 'valid multiple token' do
      let(:string) { 'send{selector=foo}' }

      let(:expected_node) do
        Mutant::AST::Pattern::Node.new(
          type:      :send,
          attribute: Mutant::AST::Pattern::Node::Attribute.new(
            name:  :selector,
            value: Mutant::AST::Pattern::Node::Attribute::Value::Single.new(value: :foo)
          )
        )
      end

      it 'returns expected node' do
        expect(apply).to eql(right(expected_node))
      end
    end

    context 'valid group attribute' do
      let(:string) { 'send{selector=(foo,bar)}' }

      let(:expected_node) do
        Mutant::AST::Pattern::Node.new(
          type:      :send,
          attribute: Mutant::AST::Pattern::Node::Attribute.new(
            name:  :selector,
            value: Mutant::AST::Pattern::Node::Attribute::Value::Group.new(
              values: [
                Mutant::AST::Pattern::Node::Attribute::Value::Single.new(value: :foo),
                Mutant::AST::Pattern::Node::Attribute::Value::Single.new(value: :bar)
              ]
            )
          )
        )
      end

      it 'returns expected node' do
        expect(apply).to eql(right(expected_node))
      end
    end

    context 'valid descendant' do
      let(:string) { 'send{receiver=const}' }

      let(:expected_node) do
        Mutant::AST::Pattern::Node.new(
          type:       :send,
          descendant: Mutant::AST::Pattern::Node::Descendant.new(
            name:    :receiver,
            pattern: Mutant::AST::Pattern::Node.new(type: :const)
          )
        )
      end

      it 'returns expected node' do
        expect(apply).to eql(right(expected_node))
      end
    end

    context 'example from docs' do
      let(:string) { <<~'PATTERN' }
        block
          { receiver = send
            { selector = log
              receiver = send{selector=logger}
            }
          }
      PATTERN

      let(:expected_node) do
        Mutant::AST::Pattern::Node.new(
          type:       :block,
          descendant: Mutant::AST::Pattern::Node::Descendant.new(
            name:    :receiver,
            pattern: Mutant::AST::Pattern::Node.new(
              type:       :send,
              attribute:  Mutant::AST::Pattern::Node::Attribute.new(
                name:  :selector,
                value: Mutant::AST::Pattern::Node::Attribute::Value::Single.new(value: :log)
              ),
              descendant: Mutant::AST::Pattern::Node::Descendant.new(
                name:    :receiver,
                pattern: Mutant::AST::Pattern::Node.new(
                  type:      :send,
                  attribute: Mutant::AST::Pattern::Node::Attribute.new(
                    name:  :selector,
                    value: Mutant::AST::Pattern::Node::Attribute::Value::Single.new(value: :logger)
                  )
                )
              )
            )
          )
        )
      end

      it 'returns expected node' do
        expect(apply).to eql(right(expected_node))
      end
    end

  end
end
