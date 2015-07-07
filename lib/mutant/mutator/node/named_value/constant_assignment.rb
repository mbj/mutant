module Mutant
  class Mutator
    class Node
      module NamedValue

        # Mutation emitter to handle constant assignment nodes
        class ConstantAssignment < Node

          children :cbase, :name, :value

          handle :casgn

        private

          # Perform dispatch
          #
          # @return [undefined]
          #
          # @api private
          def dispatch
            mutate_name
            emit_value_mutations if value
          end

          # Emit name mutations
          #
          # @return [undefined]
          #
          # @api private
          def mutate_name
            Mutator::Util::Symbol.each(name, self) do |name|
              emit_name(name.upcase)
            end
          end

        end # ConstantAssignment
      end # NamedValue
    end # Node
  end # Mutator
end # Mutant
