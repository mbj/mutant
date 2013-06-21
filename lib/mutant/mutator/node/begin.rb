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
          Util::Array.each(children) do |children|
            if children.length > 1
              emit_self(*children)
            end
          end
          children.each do |child|
            emit(child)
          end
          emit(nil)
        end

      end # Block
    end # Node
  end # Mutator
end # Mutant
