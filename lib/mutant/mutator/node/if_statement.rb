module Mutant
  class Mutator
    class Node
      # Mutator for Rubinius::AST::If nodes
      class IfStatement < self

        handle(Rubinius::AST::If)

      private

        # Emit mutations on Rubinius::AST::If nodes
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_attribute_mutations(:condition)
          emit_attribute_mutations(:body) if node.body.class != Rubinius::AST::NilLiteral
          emit_attribute_mutations(:else) if node.else.class != Rubinius::AST::NilLiteral
          emit_inverted_condition 
          emit_deleted_if_branch
          emit_deleted_else_branch
        end

        # Emit inverted condition
        #
        # Especially the same like swap branches but more universal as it also 
        # covers the case there is no else branch
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_inverted_condition
          emit_self(new_send(condition, :'!'), if_branch, else_branch)
        end

        # Emit deleted else branch
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_deleted_else_branch
          emit_self(condition, if_branch, nil)
        end

        # Emit deleted if branch
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_deleted_if_branch
          body = else_branch
          return unless body
          emit_self(condition, else_branch, nil)
        end

        # Return if_branch of node
        #
        # @return [Rubinius::AST::Node]
        #
        # @api private
        #
        def if_branch
          node.body
        end

        # Return condition of node
        #
        # @return [Rubinius::AST::Node]
        #
        # @api private
        #
        def condition
          node.condition
        end

        # Return else body of node
        #
        # @return [Rubinius::AST::Node]
        #
        # @api private
        #
        def else_branch
          node.else
        end
      end
    end
  end
end
