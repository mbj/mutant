# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Send
        # Mutator for attribute assignments
        class AttributeAssignment < self

          ATTRIBUTE_RANGE = (..-2).freeze

          private_constant(*constants(false))

        private

          def dispatch
            normal_dispatch
            emit_attribute_read
          end

          def mutate_arguments
            remaining_children_indices.each do |index|
              mutate_child(index)
            end
          end

          def emit_attribute_read
            emit_type(receiver, selector[ATTRIBUTE_RANGE].to_sym)
          end

        end # AttributeAssignment
      end # Send
    end # Node
  end # Mutator
end # Mutant
