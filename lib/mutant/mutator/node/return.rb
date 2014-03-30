# encoding: utf-8

module Mutant
  class Mutator
    class Node
      # Mutator for return statements
      class Return < self

        handle(:return)

        children :value

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          if value
            emit_value_propagation
            emit_value_mutations
          end
          emit_nil
        end

        # Emit value propagation
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_value_propagation
          return unless config.return_as_last_block_statement_value_propagation || !last_expression_in_block?
          emit(value)
        end

        # Test if node is last expression in a block
        #
        # @return [true]
        #   if currently mutated node is last expression of a block
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def last_expression_in_block?
          parent_type == :begin && parent.node.children.last.eql?(node)
        end

      end # Return
    end # Node
  end # Mutator
end # Mutant
