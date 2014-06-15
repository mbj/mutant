# encoding: UTF-8

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

            # Perform dispatch
            #
            # @return [undefined]
            #
            # @api private
            #
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
            #
            # @api private
            #
            def mutate_indices
              INDEX_RANGE.begin.upto(children.length + INDEX_RANGE.end).each do |index|
                delete_child(index)
                mutate_child(index)
              end
            end

            # Emit index read
            #
            # @return [undefined]
            #
            # @api private
            #
            def emit_index_read
              emit_type(receiver, :[], *children[INDEX_RANGE])
            end

          end # Assign
        end # Index
      end # Send
    end # Node
  end # Mutator
end # Mutant
