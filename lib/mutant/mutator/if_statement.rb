module Mutant
  class Mutator
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
        emit_condition_mutants
        emit_if_branch_mutants
        emit_else_branch_mutants
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
        emit_self(invert(condition),if_branch,else_branch)
      end

      # Emit deleted else branch
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_deleted_else_branch
        emit_self(condition,if_branch,nil)
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
        emit_self(condition,else_branch,nil)
      end

      # Return ast that returns inverted boolean value
      #
      # @param [Rubinius::Node::AST] node
      #
      # @return [Rubinius::Node::AST]
      #
      # @api private
      #
      # Using :'!' instead of :! since syntax highlighting in vim does not 
      # capture literal symbol.
      #
      def invert(node)
        if Helper.on_18?
          return new(Rubinius::AST::Not,node)
        end

        new_send(node,:'!')
      end

      # Emit mutants of condition
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_condition_mutants
        Mutator.each(condition) do |mutant|
          emit_self(mutant,if_branch,else_branch)
        end
      end

      # Emit if body mutations
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_if_branch_mutants
        Mutator.each(if_branch) do |mutant|
          emit_self(condition,mutant,else_branch)
        end
      end

      # Emit else body mutations
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_else_branch_mutants
        body = else_branch
        return unless body
        Mutator.each(body) do |mutant|
          emit_self(condition,if_branch,mutant)
        end
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
