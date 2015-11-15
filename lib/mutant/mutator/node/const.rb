module Mutant
  class Mutator
    class Node

      # Mutation emitter to handle const nodes
      class Const < Generic

        handle(:const)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        def dispatch
          emit_singletons unless parent_node && n_const?(parent_node)
          emit_type(nil, *children.drop(1))
          super
        end

      end # Const
    end # Node
  end # Mutator
end # Mutant
