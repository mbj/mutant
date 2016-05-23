module Mutant
  class Mutator
    class Node
      module Regexp
        # Generic regexp mutator
        class Generic < Node
          handle(*(AST::Types::REGEXP - %i[regexp_root_expression regexp_bol_anchor]))

          # Noop dispatch
          #
          # @return [undefined]
          def dispatch
          end
        end # Generic

        # Mutator for root expression regexp wrapper
        class RootExpression < Node
          handle(:regexp_root_expression)

          # Emit mutations for children of root node
          #
          # @return [undefined]
          def dispatch
            children.each_index(&method(:mutate_child))
          end
        end # RootExpression

        # Mutator for beginning of line anchor `^`
        class BeginningOfLineAnchor < Node
          handle(:regexp_bol_anchor)

          # Emit mutations
          #
          # Replace `^` with `\A`
          #
          # @return [undefined]
          def dispatch
            emit(s(:regexp_bos_anchor))
          end
        end # BeginningOfLineAnchor
      end # Regexp
    end # Node
  end # Mutator
end # Mutant
