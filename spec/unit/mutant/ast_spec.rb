# frozen_string_literal: true

RSpec.describe Mutant::AST do
  let(:object) { described_class.new(comment_associations: [], node: node) }

  describe '#on_line' do
    def apply(line)
      object.on_line(line)
    end

    let(:node) do
      Unparser.parse(<<~RUBY)

        begin
          1; 2
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
            described_class::View.new(node: node, path: %i[kwbegin])
          ]
        )
      end
    end

    context 'line populated with more than one' do
      it 'returns expected view' do
        expect(apply(3)).to eql(
          [
            described_class::View.new(node: s(:int, 1), path: %i[kwbegin int]),
            described_class::View.new(node: s(:int, 2), path: %i[kwbegin int])
          ]
        )
      end
    end
  end
end
