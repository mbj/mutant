# encoding: utf-8

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
          #
          # @api private
          #
          def dispatch
            emit_singletons
            emit_type
            mutate_body
            if children.one?
              emit(children.first)
            end
          end

          # Mutate body
          #
          # @return [undefined]
          #
          # @api private
          #
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
