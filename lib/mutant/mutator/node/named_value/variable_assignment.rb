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
            emit_singletons
            mutate_name
            emit_value_mutations if value # op asgn!
          end

          def mutate_name
            prefix, regexp = MAP.fetch(node.type)
            stripped = name.to_s.sub(regexp, EMPTY_STRING)
            Util::Symbol.call(input: stripped, parent: nil).each do |name|
              emit_name(:"#{prefix}#{name}")
            end
          end

        end # VariableAssignment
      end # NamedValue
    end # Node
  end # Mutator
end # Mutant
