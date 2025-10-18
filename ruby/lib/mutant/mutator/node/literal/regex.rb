# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for regexp literals
        class Regex < self

          handle(:regexp)

          # No input can ever be matched with this
          NULL_REGEXP_SOURCE = 'nomatch\A'

        private

          def options
            children.last
          end

          def dispatch
            mutate_body
            emit_singletons unless parent_node
            children.each_with_index do |child, index|
              mutate_child(index) unless n_str?(child)
            end
            emit_type(options)
            emit_type(s(:str, NULL_REGEXP_SOURCE), options)
          end

          def mutate_body
            string = Regexp.regexp_body(input) or return

            Regexp
              .mutate(::Regexp::Parser.parse(string))
              .each(&method(:emit_regexp_body))
          end

          def emit_regexp_body(expression)
            emit_type(s(:str, expression.to_str), options)
          end
        end # Regexp
      end # Literal
    end # Node
  end # Mutator
end # Mutant
