module Mutant
  class Mutator
    class Node
      # Mutator base class for assignments
      class Assignment < self

        # Mutator for variable assignment
        class Variable < self
          NAME_INDEX  = 0
          VALUE_INDEX = 1

          MAP = IceNine.deep_freeze(
            :gvasgn => '$',
            :cvasgn => '@@',
            :ivasgn => '@',
            :lvasgn => ''
          )

          handle *MAP.keys

        private

          # Perform dispatch
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            emit_name_mutations
            mutate_child(VALUE_INDEX)
          end

          # Emit name mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_name_mutations
            name = children[NAME_INDEX]
            Mutator::Util::Symbol.each(name) do |name|
              emit_child_update(NAME_INDEX, "#{MAP.fetch(node.type)}#{name}")
            end
          end

        end # Variable
      end # Assignment
    end # Node
  end # Mutator
end # Mutant
