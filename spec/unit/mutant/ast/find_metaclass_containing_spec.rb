# frozen_string_literal: true

RSpec.describe Mutant::AST::FindMetaclassContaining do
  describe '#call' do
    subject { described_class.call(ast:, target: node) }

    let(:metaclass_node) { s(:sclass, s(:self), method_node) }
    let(:method_node)    { s(:def, 'test', s(:nil))          }

    let(:node) { method_node }

    let(:ast) do
      Mutant::AST.new(
        comment_associations: [],
        node:                 metaclass_node
      )
    end

    context 'when called without node' do
      let(:node) { nil }

      specify { expect(subject).to be(nil) }
    end

    context 'when called with ast which contains a duplicate of the node' do
      let(:node) { s(:def, 'test', s(:nil)) }

      shared_examples_for 'unfooled by the duplicate node' do
        specify { expect(subject).to be(nil) }

        # if we changed method_node or node without altering the other to match,
        # the above example would provide a false positive. by ensuring node and
        # method_node are eq but not equal, we ensure the usefulness of the
        # above example.
        specify { expect(node).to eql(method_node) }
        specify { expect(node).not_to be(method_node) }
      end

      it_behaves_like 'unfooled by the duplicate node'

      context 'when the node is in a begin block' do
        let(:metaclass_node) { s(:sclass, s(:self), s(:begin, method_node)) }

        it_behaves_like 'unfooled by the duplicate node'
      end
    end

    context 'when called with ast containing the node' do
      specify { expect(subject).to be(metaclass_node) }

      context 'inside a begin block' do
        let(:metaclass_node) { s(:sclass, s(:self), s(:begin, method_node)) }

        context 'as only child' do
          it { expect(subject).to be(metaclass_node) }
        end

        context 'as sibling child' do
          let(:metaclass_node) do
            s(:sclass, s(:self), s(:begin, method_node, s(:def, 'test_2', s(:nil))))
          end

          it { expect(subject).to be(metaclass_node) }
        end
      end

      context 'inside a different class' do
        let(:metaclass_node) { s(:sclass, s(:self), s(:class, :MyClass, nil, method_node)) }

        it { expect(subject).to be(nil) }
      end
    end
  end
end
