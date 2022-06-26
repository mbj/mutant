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
            # NOTE: will only mutate parts of regexp body if the body is composed of only strings.
            # Regular expressions with interpolation are skipped.
            return unless (body_ast = AST::Regexp.expand_regexp_ast(input))

            mutate(node: body_ast).each do |mutation|
              source = AST::Regexp.to_expression(mutation).to_s
              emit_type(s(:str, source), options)
            end
          end

        end # Regex
      end # Literal
    end # Node
  end # Mutator
end # Mutant
