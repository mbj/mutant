# encoding: utf-8

module Mutant
  class Mutator
    class Node
      class Send

        # Mutator for sends that correspond to an attribute assignment
        class AttributeAssignment < self

        private

          # Emit mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            normal_dispatch
            emit_attribute_read
          end

          # Mutate arguments
          #
          # @return [undefined]
          #
          # @api private
          #
          def mutate_arguments
            remaining_children_indices.each do |index|
              mutate_child(index)
            end
          end

          # Emit attribute read
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_attribute_read
            emit_type(receiver, selector.to_s[0..-2].to_sym)
          end

        end # AttributeAssignment

      end # Send
    end # Node
  end # Mutator
end # Mutant
