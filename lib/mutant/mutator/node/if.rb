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
        def dispatch
          emit_singletons
          mutate_condition
          mutate_if_branch
          mutate_else_branch
        end

        # Emit condition mutations
        #
        # @return [undefined]
        def mutate_condition
          emit_condition_mutations do |node|
            !n_self?(node)
          end
          emit_type(n_not(condition), if_branch, else_branch) unless n_match_current_line?(condition)
          emit_type(N_TRUE,  if_branch, else_branch)
          emit_type(N_FALSE, if_branch, else_branch)
        end

        # Emit if branch mutations
        #
        # @return [undefined]
        def mutate_if_branch
          emit_type(condition, else_branch, nil) if else_branch
          return unless if_branch
          emit(if_branch)
          emit_if_branch_mutations
          emit_type(condition, if_branch, nil)
        end

        # Emit else branch mutations
        #
        # @return [undefined]
        def mutate_else_branch
          return unless else_branch
          emit(else_branch)
          emit_else_branch_mutations
          emit_type(condition, nil, else_branch)
        end

      end # If
    end # Node
  end # Mutator
end # Mutant
