# frozen_string_literal: true

RSpec.describe Mutant::AST::NamedChildren do
  describe '.included' do
    let(:klass) do
      Class.new do
        include Mutant::AST::NamedChildren, Concord.new(:node)

        children :foo, :bar
      end
    end

    def publish
      klass.class_eval do
        public :foo, :bar

        public :remaining_children, :remaining_children_indices, :remaining_children_with_index
      end
    end

    let(:instance) { klass.new(node) }

    let(:node_foo) { s(:foo) }
    let(:node_bar) { s(:bar) }
    let(:node_baz) { s(:baz) }

    let(:node) { s(:node, node_foo, node_bar, node_baz) }

    describe 'generated methods' do
      specify 'are private by default' do
        %i[
          foo
          bar
          remaining_children
          remaining_children_indices
          remaining_children_with_index
        ].each do |name|
          expect(klass.private_instance_methods.include?(name)).to be(true)
        end
      end

      describe '#remaining_children' do
        it 'returns remaining unnamed children' do
          publish
          expect(instance.remaining_children).to eql([node_baz])
        end
      end

      describe '#remaining_children_indices' do
        it 'returns remaining unnamed children indices' do
          publish
          expect(instance.remaining_children_indices).to eql([2])
        end
      end

      describe '#remaining_children_with_index' do
        it 'returns remaining unnamed children indices' do
          publish
          expect(instance.remaining_children_with_index).to eql([[node_baz, 2]])
        end
      end

      describe '#foo' do
        it 'returns named child foo' do
          publish
          expect(instance.foo).to be(node_foo)
        end
      end

      describe '#bar' do
        context 'when node is present' do
          it 'returns named child bar' do
            publish
            expect(instance.bar).to be(node_bar)
          end
        end

        context 'when node is NOT present' do
          let(:node) { s(:node, node_foo) }

          it 'returns nil' do
            publish
            expect(instance.bar).to be(nil)
          end
        end
      end
    end
  end
end
