# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      module Regexp
        # Mutator for pipe in `/foo|bar/` regexp
        class AlternationMeta < Node
          handle(:regexp_alternation_meta)

        private

          # Dispatch mutations
          #
          # @return [undefined]
          def dispatch
            children.each_index(&method(:delete_child))
          end
        end # AlternationMeta
      end # Regexp
    end # Node
  end # Mutator
end # Mutant
