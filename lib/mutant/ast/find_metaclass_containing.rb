# frozen_string_literal: true

module Mutant
  module AST
    # Given an AST, finds the sclass that directly(-ish) contains the provided
    # node.
    # This won't match arbitrarily complex structures - it only searches the
    # first level deep (no begins-in-begins, for example). This is in
    # keeping with mutant generally not supporting 'weird' syntax.
    # Descending into 'begin' nodes is supported because these are generated for
    # the one-line syntax class << self; def foo; end
    class FindMetaclassContaining
      include NodePredicates
      # index of sclass's body
      SCLASS_BODY_INDEX = 1
      # the list of node types whose children will be checked
      TRANSPARENT_NODE_TYPES = %I[begin].freeze

      # ast should be the entire AST for the file under consideration
      def initialize(ast)
        @ast = ast
      end

      def call(node)
        Mutant::AST.find_last_path(@ast) do |cur_node|
          next unless n_sclass?(cur_node)

          metaclass_of?(cur_node, node)
        end.last
      end

      private

      def metaclass_of?(sclass, node)
        body = sclass.children.fetch(SCLASS_BODY_INDEX)
        body.equal?(node) || transparently_contains?(body, node)
      end

      def transparently_contains?(body, node)
        TRANSPARENT_NODE_TYPES.include?(body.type) &&
          include_exact?(body.children, node)
      end

      def include_exact?(haystack, needle)
        !haystack.index { |elem| elem.equal?(needle) }.nil?
      end
    end
  end
end
