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
            if children.length > 1
              emit_self(*children)
            end
          end
          children.each do |child|
            emit(child)
          end
          emit(nil) unless parent_send?
        end

        # Test if parent input is a send
        #
        # @return [true]
        #   if parent input is a send node
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def parent_send?
          parent && parent.input.type == :send
        end

      end # Block
    end # Node
  end # Mutator
end # Mutant
