module Mutant
  class Mutator
    class Node
      # Mutator for if nodes
      class If < self

        handle(:if)

        CONDITION_INDEX   = 0
        IF_BRANCH_INDEX   = 1
        ELSE_BRANCH_INDEX = 2

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
          mutate_child(CONDITION_INDEX)
          emit_self(s(:send, condition, :!), if_branch, else_branch)
          emit_self(s(:true),  if_branch, else_branch)
          emit_self(s(:false), if_branch, else_branch)
        end

        # Emit if branch mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def mutate_if_branch
          mutate_child(IF_BRANCH_INDEX) if if_branch
          emit_self(condition, else_branch, nil)
          emit_self(condition, if_branch,   nil)
        end

        # Emit else branch mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def mutate_else_branch
          mutate_child(ELSE_BRANCH_INDEX)
          emit_self(condition, s(:nil), else_branch)
        end

        # Return condition node
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def condition
          children[CONDITION_INDEX]
        end

        # Return if branch
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def if_branch
          children[IF_BRANCH_INDEX]
        end

        # Return else branch
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def else_branch
          children[ELSE_BRANCH_INDEX]
        end

      end # If
    end # Node
  end # Mutator
end # Mutant
