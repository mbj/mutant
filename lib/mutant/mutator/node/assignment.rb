module Mutant
  class Mutator
    class Node

      # Abstract base class for assignment mutators
      class Assignment < self

      private

        # Abstract base class for variable assignments
        class Variable < self

          # Emit mutants
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            emit_attribute_mutations(:name) do |mutation|
              mutation.name = "#{self.class::PREFIX}#{mutation.name}".to_sym
              mutation
            end
            emit_attribute_mutations(:value)
          end

          # Mutator for local variable assignments
          class Local < self
            PREFIX = ''.freeze
            handle(:lvar)
          end # Local

          # Mutator for instance variable assignments
          class Instance < self
            PREFIX = '@'.freeze
            handle(:ivar)
          end # Instance

          # Mutator for class variable assignments
          class Class < self
            PREFIX = '@@'.freeze
            handle(:cvar)
          end # Class

          # Mutator for global variable assignments
          class Global < self
            PREFIX = '$'.freeze
            handle(:gvar)
          end # Global

        end # Access
      end # Variable
    end # Node
  end # Mutator
end # Mutant
