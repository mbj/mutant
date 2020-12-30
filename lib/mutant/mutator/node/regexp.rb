# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      module Regexp
        # Mutator for root expression regexp wrapper
        class RootExpression < Node
          handle(:regexp_root_expression)

        private

          def dispatch
            children.each_index(&method(:mutate_child))
          end
        end # RootExpression

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
