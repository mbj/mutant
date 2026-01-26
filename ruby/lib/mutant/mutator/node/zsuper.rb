# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Mutator for super without parentheses
      class ZSuper < self

        handle(:zsuper)

        include AST::Nodes

        ARGUMENTS_DESCENDANT = {
          def:  AST::Structure.for(:def).descendant(:arguments),
          defs: AST::Structure.for(:defs).descendant(:arguments)
        }.freeze

      private

        def dispatch
          emit_singletons
          emit(N_EMPTY_SUPER) if enclosing_method_has_arguments?
        end

        def enclosing_method_has_arguments?
          current = parent
          while current
            descendant = ARGUMENTS_DESCENDANT[current.node.type]
            return !descendant.value(current.node).children.empty? if descendant
            current = current.parent
          end
        end

      end # ZSuper
    end # Node
  end # Mutator
end # Mutant
