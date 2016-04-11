module Mutant
  class Mutator
    class Node
      module NamedValue

        # Mutation emitter to handle named value access nodes
        class Access < Node

          handle(:gvar, :cvar, :lvar, :self)

        private

          # Emit mutations
          #
          # @return [undefined]
          def dispatch
            emit_singletons
          end

          # Named value access emitter for instance variables
          class Ivar < Access
            NAME_RANGE = (1..-1).freeze

            handle(:ivar)

            children :name

            # Emit mutations
            #
            # @return [undefined]
            def dispatch
              emit_attribute_read
              super()
            end

          private

            # Emit instance variable as attribute send
            #
            # @return [undefined]
            def emit_attribute_read
              emit(s(:send, nil, attribute_name))
            end

            # Variable name without leading '@'
            #
            # @return [Symbol]
            def attribute_name
              name.slice(NAME_RANGE).to_sym
            end
          end # Ivar

        end # Access
      end # NamedValue
    end # Node
  end # Mutator
end # Mutant
