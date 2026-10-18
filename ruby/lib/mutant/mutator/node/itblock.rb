# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Itblock < self

        handle(:itblock)

        children :receiver, :parameter, :body

      private

        def dispatch
          emit_nil
          emit_receiver_mutations(&method(:n_send?))
          emit_body_mutations(&method(:references_it?))
        end

        def references_it?(node)
          return true if node.eql?(s(:lvar, :it))

          children = owns_it?(node) ? [node.children.first] : node.children

          children.any? do |child|
            child.instance_of?(::Parser::AST::Node) && references_it?(child)
          end
        end

        def owns_it?(node)
          n_block?(node) || n_itblock?(node) || n_def?(node) || n_defs?(node)
        end
      end # Itblock
    end # Node
  end # Mutator
end # Mutant
