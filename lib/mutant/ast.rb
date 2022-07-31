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

    def view(symbol)
      type_map.fetch(symbol, EMPTY_HASH).map do |node, path|
        View.new(node: node, path: path)
      end
    end

  private

    def type_map
      type_map = {}

      walk_path(node) do |node, path|
        path_map = type_map[node.type] ||= {}.tap(&:compare_by_identity)
        path_map[node] = path
      end

      type_map
    end
    memoize :type_map

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
