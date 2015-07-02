module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for regexp literals
        class Regex < self

          handle(:regexp)

          # No input can ever be matched with this
          NULL_REGEXP_SOURCE = 'a\A'.freeze

        private

          # Return options
          #
          # @return [Parser::AST::Node]
          #
          # @api private
          def options
            children.last
          end

          # Emit mutants
          #
          # @return [undefined]
          #
          # @api private
          def dispatch
            emit_singletons unless parent_node && n_match_current_line?(parent_node)
            children.each_with_index do |child, index|
              mutate_child(index) unless n_str?(child)
            end
            emit_type(options)
            emit_type(s(:str, NULL_REGEXP_SOURCE), options)
          end

        end # Regex
      end # Literal
    end # Node
  end # Mutator
end # Mutant
