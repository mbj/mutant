# frozen_string_literal: true

RSpec.describe Mutant::AST::FindMetaclassContaining do
  describe '#call' do
    subject { described_class.new(ast).call(node) }

    let(:metaclass_node) { s(:sclass, s(:self), method_node) }
    let(:method_node) { s(:def, 'test', s(:nil)) }

    let(:ast) { metaclass_node }
    let(:node) { method_node }

    context 'when called without ast' do
      let(:ast) { nil }

      it { expect { subject }.to raise_error }
    end

    context 'when called without node' do
      let(:node) { nil }

      it { is_expected.to be nil }
    end

    context 'when called with ast which contains a duplicate of the node' do
      let(:node) { s(:def, 'test', s(:nil)) }

      shared_examples_for 'unfooled by the duplicate node' do
        it { is_expected.to be nil }

        # if we changed method_node or node without altering the other to match,
        # the above example would provide a false positive. by ensuring node and
        # method_node are eq but not equal, we ensure the usefulness of the
        # above example.
        it { expect(node).to eq(method_node) }
        it { expect(node).not_to be method_node }
      end

      it_behaves_like 'unfooled by the duplicate node'

      context 'when the node is in a begin block' do
        let(:metaclass_node) { s(:sclass, s(:self), s(:begin, method_node)) }

        it_behaves_like 'unfooled by the duplicate node'
      end
    end

    context 'when called with ast containing the node' do
      it { is_expected.to be metaclass_node }

      context 'inside a begin block' do
        let(:metaclass_node) { s(:sclass, s(:self), s(:begin, method_node)) }

        it { is_expected.to be metaclass_node }
      end

      context 'inside a different class' do
        let(:metaclass_node) { s(:sclass, s(:self), s(:class, :MyClass, nil, method_node)) }

        it { is_expected.to be nil }
      end
    end
  end
end
