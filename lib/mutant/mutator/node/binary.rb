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

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_singletons
          emit(left)
          emit(right)
          mutate_operator
          mutate_operands
        end

        # Emit operator mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def mutate_operator
          emit(s(INVERSE.fetch(node.type), left, right))
        end

        # Emit condition mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def mutate_operands
          emit(s(node.type, n_not(left), right))
          emit(n_not(node))
        end

      end # Binary
    end # Node
  end # Mutator
end # Mutant
