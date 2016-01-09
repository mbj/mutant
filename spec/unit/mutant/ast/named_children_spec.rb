RSpec.describe Mutant::AST::NamedChildren do
  describe '.included' do
    let(:klass) do
      Class.new do
        include Mutant::AST::NamedChildren, Concord.new(:node)

        children :foo, :bar
      end
    end

    let(:instance) { klass.new(node) }

    let(:node_foo) { s(:foo) }
    let(:node_bar) { s(:bar) }
    let(:node_baz) { s(:baz) }

    let(:node) { s(:node, node_foo, node_bar, node_baz) }

    describe 'generated methods' do
      describe '#remaining_children' do
        it 'returns remaining unnamed children' do
          expect(instance.remaining_children).to eql([node_baz])
        end
      end

      describe '#remaining_children_indices' do
        it 'returns remaining unnamed children indices' do
          expect(instance.remaining_children_indices).to eql([2])
        end
      end

      describe '#remaining_children_with_index' do
        it 'returns remaining unnamed children indices' do
          expect(instance.remaining_children_with_index).to eql([[node_baz, 2]])
        end
      end

      describe '#foo' do
        it 'returns named child foo' do
          expect(instance.foo).to be(node_foo)
        end
      end

      describe '#bar' do
        context 'when node is present' do
          it 'returns named child bar' do
            expect(instance.bar).to be(node_bar)
          end
        end

        context 'when node is NOT present' do
          let(:node) { s(:node, node_foo) }

          it 'returns nil' do
            expect(instance.bar).to be(nil)
          end
        end
      end
    end
  end
end
