# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # OrAsgn mutator
      class OrAsgn < self

        handle(:or_asgn)

        children :left, :right

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          emit_singletons
          emit_right_mutations
          return if n_ivasgn?(left)
          emit_left_mutations do |node|
            AST::Types::ASSIGNABLE_VARIABLES.include?(node.type)
          end
        end

      end # OrAsgn
    end # Node
  end # Mutator
end # Mutant
