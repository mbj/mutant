module Mutant
  class Mutator
    class Node
      class Assignment < self

        class Variable < self
          NAME_INDEX  = 0
          VALUE_INDEX = 1

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
              emit_child_update(NAME_INDEX, "#{self.class::PREFIX}#{name}")
            end
          end

          class Global < self
            PREFIX = '$'.freeze
            handle(:gvasgn)
          end # Global

          class Class < self
            PREFIX = '@@'.freeze
            handle(:cvasgn)
          end # Class

          class Instance < self
            PREFIX = '@'.freeze
            handle(:ivasgn)
          end # Instance

          class Local < self
            PREFIX = ''.freeze
            handle(:lvasgn)
          end # Local

        end # Variable
      end # Assignment
    end # Node
  end # Mutator
end # Mutant
