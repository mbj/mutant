# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Mutator for while expressions
      class ConditionalLoop < self

        INVERSE = {
          until:      :while,
          until_post: :while_post,
          while:      :until,
          while_post: :until_post
        }.freeze

        handle(*INVERSE.keys)

        children :condition, :body

      private

        def dispatch
          emit_singletons
          emit_condition_mutations
          emit_type_swap
          if post?
            emit_body_mutations { |node| node.type.equal?(:kwbegin) } if body
            emit_body(s(:kwbegin, N_RAISE))
          else
            emit_body_mutations if body
            emit_body(nil)
            emit_body(N_RAISE)
          end
        end

        def post?
          node.type.to_s.end_with?('_post')
        end

        def emit_type_swap
          emit(s(INVERSE.fetch(node.type), *children))
        end

      end # ConditionalLoop
    end # Node
  end # Mutator
end # Mutant
