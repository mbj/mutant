# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Mutator for begin nodes
      class Begin < self

        handle(:begin)

      private

        def dispatch
          children.each_index do |index|
            mutate_child(index)
            delete_child(index)
          end
        end

        # rubocop:disable Lint/EmptyWhen
        # rubocop:disable Metrics/MethodLength
        def delete_child(index)
          dup_children = children.dup
          child = dup_children.delete_at(index)
          return if contains_lvar_assignment?(child)
          return if ignore?(child)

          case dup_children.length
          when 0
          when 1
            one = Mutant::Util.one(dup_children)
            return if ignore?(one)
            emit(one)
          else
            emit_type(*dup_children)
          end
        end
      end # Begin
    end # Node
  end # Mutator
end # Mutant
