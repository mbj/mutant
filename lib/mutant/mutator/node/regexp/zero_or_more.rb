# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      module Regexp
        # Mutator for zero-or-more quantifier, `*`
        class ZeroOrMore < Node
          MAP = IceNine.deep_freeze(
            regexp_greedy_zero_or_more:     :regexp_greedy_one_or_more,
            regexp_reluctant_zero_or_more:  :regexp_reluctant_one_or_more,
            regexp_possessive_zero_or_more: :regexp_possessive_one_or_more
          )

          handle(*MAP.keys)

          children :min, :max, :subject

          private

          # Replace:
          # * `/a*/`  with `/a+/`
          # * `/a*?/` with `/a+?/`
          # * `/a*+/` with `/a++/`
          def dispatch
            emit(s(MAP.fetch(node.type), *children))
            emit_subject_mutations
            emit(subject)
          end
        end # ZeroOrMore
      end # Regexp
    end # Node
  end # Mutator
end # Mutant
