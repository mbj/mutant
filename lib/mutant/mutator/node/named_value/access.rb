# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      module NamedValue

        # Mutation emitter to handle named value access nodes
        class Access < Node

          handle(:gvar, :cvar, :lvar, :self)

        private

          def dispatch
            emit_singletons
          end

          # Named value access emitter for instance variables
          class Ivar < Access
            NAME_RANGE = (1..-1)

            handle(:ivar)

            children :name

          private

            def dispatch
              emit_attribute_read
              super()
            end

            def emit_attribute_read
              emit(s(:send, nil, attribute_name))
            end

            def attribute_name
              name.slice(NAME_RANGE).to_sym
            end
          end # Ivar

        end # Access
      end # NamedValue
    end # Node
  end # Mutator
end # Mutant
