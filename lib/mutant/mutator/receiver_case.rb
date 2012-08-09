module Mutant
  class Mutator
    # Mutator for Rubinius::AST::When nodes
    class When < self

      handle(Rubinius::AST::When)

    private

      # Emit mutations
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_body_mutations
      end

      # Emit body mutations
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_body_mutations
        Mutator.each(node.body) do |mutation|
          node = dup_node
          node.body = mutation
          emit_unsafe(node)
        end
      end
    end

    # Mutator for Rubinius::AST::ReceiverCase nodes
    class ReceiverCase < self

      handle(Rubinius::AST::ReceiverCase)

    private

      # Emit mutations
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_receiver_mutations
        emit_when_branch_presence_mutations
        emit_else_branch_presence_mutation
        emit_when_branch_mutations
      end

      # Emit receiver mutation
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_receiver_mutations
        Mutator.each(receiver) do |mutant|
          emit_self(mutant,when_branches,else_branch)
        end
      end

      # Emit else branch presence mutation
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_else_branch_presence_mutation
        emit_self(receiver,when_branches,nil)
      end

      # Emit when branch body mutations
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_when_branch_mutations
        when_branches.each_with_index do |branch,index|
          Mutator.each(branch) do |mutant|
            branches = dup_when_branches
            branches[index]=mutant
            emit_self(receiver,branches,else_branch)
          end
        end
      end

      # Emit when branch presence mutations
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_when_branch_presence_mutations
        return if one?
        when_branches.each_index do |index|
          dup_branches = dup_when_branches
          dup_branches.delete_at(index)
          emit_self(receiver,dup_branches,else_branch)
        end
      end

      # Check for case there is only one when branch
      #
      # @return [true]
      #   returns true when there is only one when branch
      #
      # @return [false]
      #   returns false otherwise
      #
      # @api private
      #
      def one?
        when_branches.one?
      end

      # Return duplicate of when branches
      #
      # @return [Array]
      #
      # @api private
      #
      def dup_when_branches
        when_branches.dup
      end

      # Return when branches
      #
      # @return [Array]
      #
      # @api private
      #
      def when_branches
        node.whens
      end

      # Return receiver
      #
      # @return [Rubinius::AST::Node]
      #
      # @api private
      #
      def receiver
        node.receiver
      end

      # Return else branch
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
