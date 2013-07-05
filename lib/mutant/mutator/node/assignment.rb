module Mutant
  class Mutator
    class Node
      # Mutator base class for assignments
      class Assignment < self

        # Mutator for variable assignment
        class Variable < self

          children :name, :value

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
            mutate_name
            emit_value_mutations if value # mlhs!
          end

          # Emit name mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def mutate_name
            prefix = MAP.fetch(node.type)
            Mutator::Util::Symbol.each(name, self) do |name|
              emit_name("#{prefix}#{name}")
            end
          end

        end # Variable
      end # Assignment
    end # Node
  end # Mutator
end # Mutant
