# frozen_string_literal: true

RSpec.describe Mutant::AST do
  let(:object) { described_class }

  describe '.find_last_path' do
    subject { object.find_last_path(root, &block) }

    let(:root)    { s(:root, parent)             }
    let(:child_a) { s(:child_a)                  }
    let(:child_b) { s(:child_b)                  }
    let(:parent)  { s(:parent, child_a, child_b) }

    def path
      subject.map(&:type)
    end

    context 'when no node matches' do
      let(:block) { ->(_) { false } }

      it { should eql([]) }
    end

    context 'when called without block' do
      let(:block) { nil }

      it 'raises error' do
        expect { subject }.to raise_error(ArgumentError, 'block expected')
      end
    end

    context 'on non Parser::AST::Node child' do
      let(:block)   { ->(node) { fail if node.equal?(child_a) } }
      let(:child_a) { AST::Node.new(:foo) }

      it 'does not yield that node' do
        expect(path).to eql([])
      end
    end

    context 'when one node matches' do
      let(:block) { ->(node) { node.equal?(child_a) } }

      it 'returns the full path' do
        expect(path).to eql(%i[root parent child_a])
      end
    end

    context 'when two nodes match' do
      let(:block) { ->(node) { node.equal?(child_a) || node.equal?(child_b) } }

      it 'returns the last full path' do
        expect(path).to eql(%i[root parent child_b])
      end
    end
  end
end
