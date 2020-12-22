# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Mutator for dynamic literals
      class DynamicLiteral < self

        handle(:dstr, :dsym)

      private

        def dispatch
          emit_singletons

          children.each_index do |index|
            mutate_child(index, &method(:n_begin?))
          end
        end

      end # DynamicLiteral
    end # Node
  end # Mutator
end # Mutant
