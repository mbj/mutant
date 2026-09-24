# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Mutator for dynamic literals
      class DynamicLiteral < self

        handle(:dstr, :dsym, :xstr)

      private

        def dispatch
          emit_singletons

          if SqlHeredoc.sql_heredoc?(input)
            emit(N_EMPTY_STRING)
            SqlHeredoc.mutate(input).each(&method(:emit))
          else
            children.each_index do |index|
              mutate_child(index, &method(:n_begin?))
            end
          end
        end

      end # DynamicLiteral
    end # Node
  end # Mutator
end # Mutant
