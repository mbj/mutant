# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      module Regexp
        # Mutator for beginning of line anchor `^`
        class BeginningOfLineAnchor < Node
          handle(:regexp_bol_anchor)

          private

          def dispatch
            emit(s(:regexp_bos_anchor))
          end
        end # BeginningOfLineAnchor
      end # Regexp
    end # Node
  end # Mutator
end # Mutant
