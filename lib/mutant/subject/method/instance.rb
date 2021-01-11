# frozen_string_literal: true

module Mutant
  class Subject
    class Method
      # Instance method subjects
      class Instance < self

        NAME_INDEX = 0
        SYMBOL     = '#'

        # Prepare subject for mutation insertion
        #
        # @return [self]
        def prepare
          scope.undef_method(name)
          self
        end

        # Mutator for memoizable memoized instance methods
        class Memoized < self
          include AST::Sexp

          # Prepare subject for mutation insertion
          #
          # @return [self]
          def prepare
            scope
              .instance_variable_get(:@memoized_methods)
              .delete(name)

            super()
          end

        private

          def wrap_node(mutant)
            s(:begin, mutant, s(:send, nil, :memoize, s(:sym, name)))
          end
        end # Memoized
      end # Instance
    end # Method
  end # Subject
end # Mutant
