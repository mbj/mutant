module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for regexp literals
        class Regex < self

          handle(:regexp)

          EMPTY_STRING = ''.freeze

          # No input can ever be matched with this
          NULL_REGEXP_SOURCE = 'a\A'.freeze

          SOURCE_INDEX, OPTIONS_INDEX = 0, 1

        private

          # Emit mutants
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            emit_nil
            emit_self(s(:str, EMPTY_STRING), options)
            emit_self(s(:str, NULL_REGEXP_SOURCE), options)
          end

          def options
            children[OPTIONS_INDEX]
          end

          def source
            children[SOURCE_INDEX]
          end

        end # Regex
      end # Literal
    end # Node
  end # Mutator
end # Mutant
