module Mutant
  class Mutator
    class Node
      # Mutator for if nodes
      class If < self

        handle(:if)

      private

        # Emit mutations 
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_attribute_mutations(:condition)
          emit_attribute_mutations(:body) unless nil_literal?(:body)
          emit_attribute_mutations(:else) unless nil_literal?(:else)
          emit_inverted_condition
          emit_deleted_if_branch
          emit_deleted_else_branch
          emit_true_if_branch
          emit_false_if_branch
        end

        # Test if attribute is non nil literal
        #
        # @param [Symbol] name
        #
        # @return [true]
        #   if attribute value a nil literal
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def nil_literal?(name)
          node.public_send(name).kind_of?(Rubinius::AST::NilLiteral)
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
          body = else_branch || return
          emit_self(condition, body, nil)
        end

        # Emit true if branch
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_true_if_branch
          emit_self(new(Rubinius::AST::TrueLiteral), if_branch, else_branch)
        end

        # Emit false if branch
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_false_if_branch
          emit_self(new(Rubinius::AST::FalseLiteral), if_branch, else_branch)
        end

        # Return if_branch of node
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def if_branch
          node.body
        end

        # Return condition of node
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def condition
          node.condition
        end

        # Return else body of node
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def else_branch
          node.else
        end

      end # If
    end # Node
  end # Mutator
end # Mutant
