module Mutant
  class Mutator
    class Node
      module Regexp
        # Mutator for greedy zero-or-more quantifier, `*`
        class GreedyZeroOrMore < Node
          handle(:regexp_greedy_zero_or_more)

          children :min, :max, :subject

          # Emit mutations
          #
          # Replace `/a*/` with `/a+/`
          #
          # @return [undefined]
          def dispatch
            emit(s(:regexp_greedy_one_or_more, *children))
            emit_subject_mutations
            emit(subject)
          end
        end # GreedyZeroOrMore
      end # Regexp
    end # Node
  end # Mutator
end # Mutant
