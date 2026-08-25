# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Literal
        # Mutator for string literals
        class String < self

          handle(:str)

          # Pattern to extract the heredoc tag name from expressions like
          # +<<~SQL+, +<<-SQL+, or +<<SQL+.
          HEREDOC_TAG = /<<?-?~?(\w+)/

        private

          def dispatch
            emit_singletons
            emit(N_EMPTY_STRING)
            emit_sql_mutations if sql_heredoc?
          end

          def sql_heredoc?
            location = input.location or return false
            return false unless location.kind_of?(::Parser::Source::Map::Heredoc)

            HEREDOC_TAG.match(location.expression.source) do |match|
              break match[1].upcase.eql?('SQL')
            end
          end

          def emit_sql_mutations
            Sql.mutate(input.children.first).each do |mutated|
              emit(s(:str, mutated))
            end
          end

        end # String
      end # Literal
    end # Node
  end # Mutator
end # Mutant
