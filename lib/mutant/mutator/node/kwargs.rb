# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Mutator for kwargs node
      class Kwargs < self

        handle(:kwargs)

      private

        def dispatch
          emit_argument_presence
          emit_argument_mutations
        end

        def emit_argument_presence
          Util::Array::Presence.call(children).each do |children|
            emit_type(*children)
          end
        end

        def emit_argument_mutations
          children.each_with_index do |child, index|
            Mutator.mutate(child).each do |mutant|
              emit_child_update(index, mutant)
            end
          end
        end
      end # Kwargs
    end # Node
  end # Mutator
end # Mutant
