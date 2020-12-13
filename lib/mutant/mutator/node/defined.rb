# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Namespace for `defined?` mutations
      class Defined < self

        handle(:defined?)

        children :expression

      private

        def dispatch
          emit_singletons
          emit(N_TRUE)

          emit_expression_mutations { |node| !n_self?(node) }
          emit_instance_variable_mutation
        end

        def emit_instance_variable_mutation
          return unless n_ivar?(expression)

          instance_variable_name = Mutant::Util.one(expression.children)

          emit(
            s(:send, nil, :instance_variable_defined?,
              s(:sym, instance_variable_name))
          )
        end

      end # Defined
    end # Node
  end # Mutator
end # Mutant
