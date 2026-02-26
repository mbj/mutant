# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Regular expression options mutation
      class Regopt < self

        MUTATED_FLAGS = %i[i m].freeze

        handle(:regopt)

      private

        def dispatch
          MUTATED_FLAGS.each do |flag|
            emit_type(*(children - [flag]))
          end
        end

      end # Regopt
    end # Node
  end # Mutator
end # Mutant
