# frozen_string_literal: true

module Mutant
  # AST helpers
  module AST

    # Find last node satisfying predicate (as block)
    #
    # @return [Parser::AST::Node]
    #   if satisfying node is found
    #
    # @yield [Parser::AST::Node]
    #
    # @yieldreturn [Boolean]
    #   true in case node satisfies predicate
    #
    # @return [nil]
    #   otherwise
    def self.find_last_path(node, &predicate)
      fail ArgumentError, 'block expected' unless block_given?
      path = []
      walk(node, [node]) do |candidate, stack|
        if predicate.call(candidate)
          path = stack.dup
        end
      end
      path
    end

    def self.walk(node, stack, &block)
      block.call(node, stack)
      node.children.grep(::Parser::AST::Node) do |child|
        stack.push(child)
        walk(child, stack, &block)
        stack.pop
      end
    end
    private_class_method :walk

  end # AST
end # Mutant
