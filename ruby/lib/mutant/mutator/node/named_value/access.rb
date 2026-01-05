# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      module NamedValue

        # Mutation emitter to handle named value access nodes
        class Access < Node

          handle(:gvar, :cvar, :ivar, :lvar, :self)

        private

          def dispatch
            emit_singletons
          end

        end # Access
      end # NamedValue
    end # Node
  end # Mutator
end # Mutant
