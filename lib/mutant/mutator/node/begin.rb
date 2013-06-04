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
          Mutator::Util::Array.each(children) do |children|
            emit_self(children)
          end
        end

      end # Block
    end # Node
  end # Mutator
end # Mutant
