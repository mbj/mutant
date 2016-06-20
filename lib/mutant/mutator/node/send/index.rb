module Mutant
  class Mutator
    class Node
      class Send
        # Base mutator for index operations
        class Index < self

          # Mutator for index assignments
          class Assign < self

            define_named_child(:value, -1)

            INDEX_RANGE = (2..-2).freeze

          private

            # Emit mutations
            #
            # @return [undefined]
            def dispatch
              emit_naked_receiver
              emit_value_mutations
              emit_index_read
              emit(value)
              mutate_indices
            end

            # Mutate indices
            #
            # @return [undefined]
            def mutate_indices
              children_indices(INDEX_RANGE).each do |index|
                delete_child(index)
                mutate_child(index)
              end
            end

            # Emit index read
            #
            # @return [undefined]
            def emit_index_read
              emit_type(receiver, :[], *children[INDEX_RANGE])
            end

          end # Assign
        end # Index
      end # Send
    end # Node
  end # Mutator
end # Mutant
