# frozen_string_literal: true

RSpec.describe Mutant::AST::Structure do
  describe '.for' do
    def apply
      described_class.for(type)
    end

    let(:type) { :str }

    it 'returns expected structure' do
      expect(apply).to eql(
        described_class::Node.new(
          type:     :str,
          fixed:    [
            described_class::Node::Fixed::Attribute.new(
              index: 0,
              name:  :value
            )
          ],
          variable: nil
        )
      )
    end
  end

  describe '#each_node' do
    def all_nodes(node)
      [node, *node.children.grep(Parser::AST::Node).flat_map { |child| all_nodes(child) }]
    end

    def walked_nodes(node)
      nodes = []
      described_class.for(node.type).each_node(node) { |child| nodes << child }
      nodes
    end

    [
      'x in {a: ^(b), **nil}',
      'x in [*, ^(b), *]',
      'x in [^(b),]',
      'x in ^(b) | ^(c)',
      'x in ^(b) => c',
      'def foo(**nil); end'
    ].each do |source|
      it "visits every node of #{source}" do
        node = parse(source)

        expect(walked_nodes(node).map(&:__id__)).to match_array(all_nodes(node).map(&:__id__))
      end
    end
  end
end
