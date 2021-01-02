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
      end # Regexp
    end # Node
  end # Mutator
end # Mutant
