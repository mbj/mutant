# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class BlockPass < self

        handle(:block_pass)

        children :argument

      private

        def dispatch
          return unless argument
          emit_argument_mutations
          emit_symbol_to_proc_mutations
        end

        def emit_symbol_to_proc_mutations
          return unless n_sym?(argument)

          Send::SELECTOR_REPLACEMENTS.fetch(*argument, EMPTY_ARRAY).each do |method|
            emit_argument(s(:sym, method))
          end
        end
      end # Block
    end # Node
  end # Mutator
end # Mutant
