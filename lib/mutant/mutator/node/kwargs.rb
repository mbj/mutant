# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Mutator for kwargs node
      class Kwargs < self

        DISALLOW = %i[nil self].freeze

        private_constant(*constants(false))

        handle(:kwargs)

      private

        def dispatch
          emit_argument_presence
          emit_argument_mutations
        end

        def emit_argument_presence
          Util::Array::Presence.call(children).each do |children|
            emit_type(*children) unless children.empty?
          end
        end

        def emit_argument_mutations
          children.each_with_index do |child, index|
            Mutator.mutate(child).each do |mutant|
              unless forbid_argument?(mutant)
                emit_child_update(index, mutant)
              end
            end
          end
        end

        def forbid_argument?(node)
          n_pair?(node) && DISALLOW.include?(node.children.first.type)
        end
      end # Kwargs
    end # Node
  end # Mutator
end # Mutant
