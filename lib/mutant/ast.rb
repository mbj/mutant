# frozen_string_literal: true

module Mutant
  class AST
    include Adamantium, Anima.new(
      :node,
      :comment_associations
    )

    class View
      include Adamantium, Anima.new(:node, :stack)
    end

    def on_line(line)
      line_map.fetch(line, EMPTY_HASH).map do |node, stack|
        View.new(node: node, stack: stack)
      end
    end

  private

    def line_map
      line_map = {}

      walk_path(node, []) do |node, stack|
        expression = node.location.expression || next
        (line_map[expression.line] ||= []) << [node, stack]
      end

      line_map
    end
    memoize :line_map

    def walk_path(node, stack, &block)
      block.call(node, stack)
      stack = [*stack, node]
      node.children.grep(::Parser::AST::Node) do |child|
        walk_path(child, stack, &block)
      end
    end
  end # AST
end # Mutant
