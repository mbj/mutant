# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Send
        # Mutator for attribute assignments
        class AttributeAssignment < self

          ATTRIBUTE_RANGE = (0..-2).freeze
          private_constant(*constants(false))

        private

          # Emit mutations
          #
          # @return [undefined]
          def dispatch
            normal_dispatch
            emit_attribute_read
          end

          # Mutate arguments
          #
          # @return [undefined]
          def mutate_arguments
            remaining_children_indices.each do |index|
              mutate_child(index)
            end
          end

          # Emit attribute read
          #
          # @return [undefined]
          def emit_attribute_read
            emit_type(receiver, selector[ATTRIBUTE_RANGE].to_sym)
          end

        end # AttributeAssignment
      end # Send
    end # Node
  end # Mutator
end # Mutant
