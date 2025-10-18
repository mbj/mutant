# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      module NamedValue

        # Mutation emitter to handle variable assignment nodes
        class VariableAssignment < Node

          children :name, :value

          map = {
            gvasgn: '$',
            cvasgn: '@@',
            ivasgn: '@',
            lvasgn: EMPTY_STRING
          }

          MAP = map
            .transform_values { |prefix| [prefix, /^#{::Regexp.escape(prefix)}/] }
            .freeze

          handle(*MAP.keys)

        private

          def dispatch
            emit_value_mutations if value # op asgn!
          end
        end # VariableAssignment
      end # NamedValue
    end # Node
  end # Mutator
end # Mutant
