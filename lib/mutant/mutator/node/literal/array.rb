module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for array literals
        class Array < self

          handle(:array)

        private

          # Emit mutations
          #
          # @return [undefined]
          def dispatch
            emit_singletons
            emit_type
            mutate_body
            return unless children.one?
            emit(children.first)
          end

          # Mutate body
          #
          # @return [undefined]
          def mutate_body
            children.each_index do |index|
              dup_children = children.dup
              dup_children.delete_at(index)
              emit_type(*dup_children)
              mutate_child(index)
            end
          end

        end # Array
      end # Literal
    end # Node
  end # Mutator
end # Mutant
