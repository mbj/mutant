# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Mutator for rescue nodes
      class Rescue < self

        handle :rescue

        children :body

        define_named_child(:else_body, -1)

        RESCUE_INDICES = (1..-2)

      private

        def dispatch
          mutate_body
          mutate_rescue_bodies
          mutate_else_body
        end

        def mutate_rescue_bodies
          children_indices(RESCUE_INDICES).each do |index|
            mutate_child(index)
            resbody = AST::Meta::Resbody.new(node: children.fetch(index))
            if resbody.body && !resbody.assignment
              emit_concat(resbody.body)
            end
          end
        end

        def emit_concat(child)
          if body
            emit(s(:begin, body, child))
          else
            emit(child)
          end
        end

        def mutate_body
          return unless body
          emit_body_mutations
          emit(body)
        end

        def mutate_else_body
          return unless else_body
          emit_else_body_mutations
          emit_concat(else_body)
        end

      end # Rescue
    end # Node
  end # Mutator
end # Mutant
