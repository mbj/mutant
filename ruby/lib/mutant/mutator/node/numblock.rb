# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Numblock < self

        handle(:numblock)

        children :receiver, :count, :block

      private

        def dispatch
          emit_nil
          emit_receiver_mutations(&method(:n_send?))
        end
      end # Numblock
    end # Node
  end # Mutator
end # Mutant
