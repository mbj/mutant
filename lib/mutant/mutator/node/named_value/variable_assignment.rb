# encoding: utf-8

module Mutant
  class Mutator
    class Node
      module NamedValue

        # Mutation emitter to handle variable assignment nodes
        class VariableAssignment < Node

          children :name, :value

          MAP = IceNine.deep_freeze(
            gvasgn: '$',
            cvasgn: '@@',
            ivasgn: '@',
            lvasgn: ''
          )

          handle(*MAP.keys)

        private

          # Perform dispatch
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            mutate_name
            emit_value_mutations if value # mlhs!
            emit_nil
          end

          # Emit name mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def mutate_name
            prefix = MAP.fetch(node.type)
            Mutator::Util::Symbol.each(inherit_context(name)) do |name|
              emit_name(prefix + name.to_s)
            end
          end

        end # VariableAssignment
      end # NamedValue
    end # Node
  end # Mutator
end # Mutant
