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
            emit_empty_set
            return unless children.one?
            emit(Mutant::Util.one(children))
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

          # Emit `Set.new`
          #
          # @return [undefined]
          def emit_empty_set
            emit(s(:send, s(:const, nil, :Set), :new)) if children.empty?
          end

        end # Array
      end # Literal
    end # Node
  end # Mutator
end # Mutant
