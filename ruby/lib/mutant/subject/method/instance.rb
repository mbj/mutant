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
        def prepare = tap { scope.raw.undef_method(name) }

        def post_insert = tap { scope.raw.__send__(visibility, name) }

        # Mutator for memoizable memoized instance methods
        class Memoized < self
          include AST::Sexp

          # Prepare subject for mutation insertion
          #
          # @return [self]
          def prepare
            scope
              .raw
              .instance_variable_get(:@memoized_methods)
              .delete(name)

            super
          end

        private

          def wrap_node(mutant)
            s(:begin, mutant, s(:send, nil, :memoize, s(:sym, name)))
          end
        end # Memoized

        # Subject for instance methods exposed via module_function
        #
        # module_function copies the method onto the module's singleton
        # class. Redefining only the instance method would leave that copy,
        # which callers use, unmutated.
        class ModuleFunction < self

          # Prepare subject for mutation insertion
          #
          # @return [self]
          def prepare
            scope.raw.singleton_class.undef_method(name)

            super
          end

          # Copy the inserted method onto the singleton class again
          #
          # @return [self]
          def post_insert = tap { scope.raw.__send__(:module_function, name) }
        end # ModuleFunction
      end # Instance
    end # Method
  end # Subject
end # Mutant
