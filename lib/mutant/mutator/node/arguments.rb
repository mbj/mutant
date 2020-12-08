# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Mutator for arguments node
      class Arguments < self

        handle(:args)

        PROCARG = %i[restarg mlhs].freeze

      private

        def dispatch
          emit_argument_presence
          emit_argument_mutations
          emit_mlhs_expansion
        end

        def emit_argument_presence
          emit_type

          Util::Array::Presence.call(children).each do |children|
            unless children.one? && n_mlhs?(children.first)
              emit_type(*children)
            end
          end
        end

        def emit_argument_mutations
          children.each_with_index do |child, index|
            Mutator.mutate(child).each do |mutant|
              next if invalid_argument_replacement?(mutant, index)
              emit_child_update(index, mutant)
            end
          end
        end

        def invalid_argument_replacement?(mutant, index)
          n_arg?(mutant) && children[0...index].any?(&method(:n_optarg?))
        end

        def emit_mlhs_expansion
          mlhs_childs_with_index.each do |child, index|
            dup_children = children.dup
            dup_children.delete_at(index)
            dup_children.insert(index, *child)
            emit_type(*dup_children)
          end
        end

        def mlhs_childs_with_index
          children.each_with_index.select do |child,|
            n_mlhs?(child)
          end
        end

      end # Arguments
    end # Node
  end # Mutator
end # Mutant
