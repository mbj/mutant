# frozen_string_literal: true

RSpec.describe Mutant::AST do
  let(:object) { described_class.new(comment_associations: [], node: node) }

  describe '#view' do
    def apply(symbol)
      object.view(symbol)
    end

    let(:node) do
      s(:begin, s(:int, 1), s(:int, 2), s(:int, 3))
    end

    context 'on not matched node' do
      it 'returns empty view' do
        expect(apply(:send)).to eql([])
      end
    end

    context 'on root node' do
      it 'returns expected view' do
        expect(apply(:begin)).to eql(
          [
            described_class::View.new(node: node, path: %i[begin])
          ]
        )
      end
    end

    context 'on descendant node' do
      it 'returns expected view' do
        expect(apply(:int)).to eql(
          [
            described_class::View.new(node: s(:int, 1), path: %i[begin int]),
            described_class::View.new(node: s(:int, 2), path: %i[begin int]),
            described_class::View.new(node: s(:int, 3), path: %i[begin int])
          ]
        )
      end
    end
  end
end
