module Mutant
  class Mutator
    class Node
      module Regexp
        # Mutator for end of line anchor `$`
        class EndOfLineAnchor < Node
          handle(:regexp_eol_anchor)

          # Emit mutations
          #
          # Replace `$` with `\z`
          #
          # @return [undefined]
          def dispatch
            emit(s(:regexp_eos_anchor))
          end
        end # EndOfLineAnchor
      end # Regexp
    end # Node
  end # Mutator
end # Mutant
