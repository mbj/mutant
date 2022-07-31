# frozen_string_literal: true

module Mutant
  class AST
    include Adamantium, Anima.new(
      :node,
      :comment_associations
    )

    class View
      include Adamantium, Anima.new(:node, :path)
    end

    def on_line(line)
      line_map.fetch(line, EMPTY_HASH).map do |node, path|
        View.new(node: node, path: path)
      end
    end

  private

    def line_map
      line_map = {}

      walk_path(node) do |node, path|
        expression = node.location.expression || next
        (line_map[expression.line] ||= []) << [node, path]
      end

      line_map
    end
    memoize :line_map

    def walk_path(node, stack = [node.type], &block)
      block.call(node, stack.dup)
      node.children.grep(::Parser::AST::Node) do |child|
        stack.push(child.type)
        walk_path(child, stack, &block)
        stack.pop
      end
    end
  end # AST
end # Mutant
