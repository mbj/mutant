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
          emit_singletons if standalone?
        end

        def standalone?
          parent_type.nil?
        end

        def mutate_rescue_bodies
          children_indices(RESCUE_INDICES).each do |index|
            mutate_child(index)
            resbody = AST::Meta::Resbody.new(node: children.fetch(index))
            if resbody.body && !resbody.assignment
              emit_concat(resbody.body)
            end
          end
          emit_rescue_clause_removals
          emit_handler_promotion
        end

        def emit_handler_promotion
          return unless standalone?

          children_indices(RESCUE_INDICES).each do |index|
            resbody = AST::Meta::Resbody.new(node: children.fetch(index))
            emit(resbody.body)
          end
        end

        def emit_rescue_clause_removals
          rescue_indices = children_indices(RESCUE_INDICES).to_a
          return unless rescue_indices.length > 1

          rescue_indices.each do |index|
            dup_children = children.dup
            dup_children.delete_at(index)
            emit_type(*dup_children)
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
