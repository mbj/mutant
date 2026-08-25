# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Literal
        # Mutator for string literals
        class String < self

          handle(:str)

          # Detection and mutation of SQL heredoc bodies
          module SqlHeredoc
            # Pattern to extract the heredoc tag name from expressions like
            # +<<~SQL+, +<<-SQL+, or +<<SQL+.
            HEREDOC_TAG = /<<?-?~?(\w+)/

            # Generate mutations for SQL heredoc bodies
            #
            # @param [Parser::AST::Node] node
            #
            # @return [Set<Parser::AST::Node>]
            def self.mutate(node)
              return Set.new unless sql_heredoc?(node)

              Mutant::Mutator::Sql.mutate(node.children.first).each_with_object(Set.new) do |mutated, set|
                set << ::Parser::AST::Node.new(:str, [mutated])
              end
            end

            def self.sql_heredoc?(node)
              location = node.location or return false
              return false unless location.kind_of?(::Parser::Source::Map::Heredoc)

              HEREDOC_TAG.match(location.expression.source) do |match|
                break match[1].upcase.eql?('SQL')
              end
            end

            private_class_method :sql_heredoc?
          end # SqlHeredoc

        private

          def dispatch
            emit_singletons
            emit(N_EMPTY_STRING)
            SqlHeredoc.mutate(input).each(&method(:emit))
          end

        end # String
      end # Literal
    end # Node
  end # Mutator
end # Mutant
