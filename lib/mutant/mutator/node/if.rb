module Mutant
  class Mutator
    class Node
      # Mutator for if nodes
      class If < self

        handle(:if)

        children :condition, :if_branch, :else_branch

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          mutate_condition
          mutate_if_branch
          mutate_else_branch
        end

        # Emit conditon mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def mutate_condition
          emit_condition_mutations
          emit_self(s(:send, condition, :!), if_branch, else_branch)
          emit_self(N_TRUE,  if_branch, else_branch)
          emit_self(N_FALSE, if_branch, else_branch)
        end

        # Emit if branch mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def mutate_if_branch
          emit_self(condition, else_branch, nil) if else_branch
          if if_branch
            emit_if_branch_mutations
            emit_self(condition, if_branch, nil)
          end
        end

        # Emit else branch mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def mutate_else_branch
          if else_branch
            emit_else_branch_mutations
            emit_self(condition, nil, else_branch)
          end
        end

      end # If
    end # Node
  end # Mutator
end # Mutant
