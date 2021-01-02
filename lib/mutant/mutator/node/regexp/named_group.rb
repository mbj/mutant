# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      module Regexp
        # Mutator for regexp named capture groups, such as `/(?<foo>bar)/`
        class NamedGroup < Node
          handle(:regexp_named_group)

          children :name, :group

        private

          def dispatch
            return unless group

            emit(s(:regexp_passive_group, group))
            emit_group_mutations
          end
        end # EndOfLineAnchor
      end # Regexp
    end # Node
  end # Mutator
end # Mutant
