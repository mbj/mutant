module Mutant
  class Mutator
    class Node

      # Mutator for begin nodes
      class Begin < self

        handle(:begin)

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          Util::Array.each(children, self) do |children|
            emit_child_subset(children)
          end
          children.each_with_index do |child, index|
            mutate_child(index)
            emit(child) unless children.eql?([child])
          end
        end

        # Emit child subset
        #
        # @param [Array<Parser::AST::Node>] nodes
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_child_subset(children)
          return if children.length < 2
          emit_type(*children)
        end

      end # Block
    end # Node
  end # Mutator
end # Mutant
