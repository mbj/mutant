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

          # Original regexp options
          #
          # @return [Parser::AST::Node]
          def options
            children.last
          end

          # Emit mutations
          #
          # @return [undefined]
          def dispatch
            mutate_body
            emit_singletons unless parent_node
            children.each_with_index do |child, index|
              mutate_child(index) unless n_str?(child)
            end
            emit_type(options)
            emit_type(s(:str, NULL_REGEXP_SOURCE), options)
          end

          # Mutate regexp body
          #
          # @note will only mutate parts of regexp body if the
          # body is composed of only strings. Regular expressions
          # with interpolation are skipped
          #
          # @return [undefined]
          def mutate_body
            return unless body.all?(&method(:n_str?)) && body_ast

            Mutator.mutate(body_ast).each do |mutation|
              source = AST::Regexp.to_expression(mutation).to_s
              emit_type(s(:str, source), options)
            end
          end

          # AST representation of regexp body
          #
          # @return [Parser::AST::Node, nil]
          def body_ast
            body_expression and AST::Regexp.to_ast(body_expression)
          end

          # Expression representation of regexp body
          #
          # @return [Regexp::Expression, nil]
          def body_expression
            AST::Regexp.parse(body.map(&:children).join)
          end
          memoize :body_expression

          # Children of regexp node which compose regular expression source
          #
          # @return [Array<Parser::AST::Node>]
          def body
            children.slice(0...-1)
          end

        end # Regex
      end # Literal
    end # Node
  end # Mutator
end # Mutant
