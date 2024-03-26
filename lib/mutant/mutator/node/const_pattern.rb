# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class ConstPattern < self
        handle(:const_pattern)

        children(:target, :pattern)

      private

        def dispatch; end

      end # ConstPAttern
    end # Node
  end # Mutator
end # Mutant
