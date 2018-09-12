# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Emitter for perl style match current line node
      class MatchCurrentLine < self

        handle :match_current_line

        children :regexp

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          emit_singletons
          emit_regexp_mutations
        end

      end # MatchCurrentLine
    end # Node
  end # Mutator
end # Mutant
