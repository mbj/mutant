# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      module Regexp
        # Mutator for end of line or before end of string anchor `\Z`
        class EndOfStringOrBeforeEndOfLineAnchor < Node
          handle(:regexp_eos_ob_eol_anchor)

          # Emit mutations
          #
          # Replace `\Z` with `\z`
          #
          # @return [undefined]
          def dispatch
            emit(s(:regexp_eos_anchor))
          end
        end # EndOfStringOrBeforeEndOfLineAnchor
      end # Regexp
    end # Node
  end # Mutator
end # Mutant
