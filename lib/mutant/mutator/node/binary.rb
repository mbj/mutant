# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Mutation emitter to handle binary connectives
      class Binary < self

        INVERSE = {
          and: :or,
          or:  :and
        }.freeze

        handle(*INVERSE.keys)

        children :left, :right

      private

        def dispatch
          emit_singletons
          emit_promotions
          emit_operator_mutations

          emit_left_mutations do |mutation|
            !(n_irange?(mutation) || n_erange?(mutation)) || !mutation.children.fetch(1).nil?
          end

          emit_right_mutations
        end

        def emit_operator_mutations
          emit(s(INVERSE.fetch(node.type), left, right))
        end

        def emit_promotions
          emit(left)
          emit(right)
        end

      end # Binary
    end # Node
  end # Mutator
end # Mutant
