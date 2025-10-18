# frozen_string_literal: true

RSpec.describe Mutant::AST do
  let(:object) { described_class.new(comment_associations: [], node:) }

  describe '#on_line' do
    def apply(line)
      object.on_line(line)
    end

    let(:node) do
      Unparser.parse(<<~RUBY)

        def foo
          begin
            1; 2
          end
        end
      RUBY
    end

    context 'unpopulated line' do
      it 'returns empty view' do
        expect(apply(1)).to eql([])
      end
    end

    context 'line populated with one node' do
      it 'returns expected view' do
        expect(apply(2)).to eql(
          [
            described_class::View.new(node:, stack: [])
          ]
        )
      end
    end

    context 'line populated with more than one' do
      it 'returns expected view' do
        expect(apply(4)).to eql(
          [
            described_class::View.new(node: s(:int, 1), stack: [node, node.children.fetch(2)]),
            described_class::View.new(node: s(:int, 2), stack: [node, node.children.fetch(2)])
          ]
        )
      end
    end
  end
end
