module Mutant
  class Subject
    class Method
      # Instance method subjects
      class Instance < self

        NAME_INDEX = 0
        SYMBOL     = '#'.freeze

        # Prepare subject for mutation insertion
        #
        # @return [self]
        def prepare
          scope.__send__(:undef_method, name)
          self
        end

        # Mutator for memoizable memoized instance methods
        class Memoized < self
          include AST::Sexp

          # Prepare subject for mutation insertion
          #
          # @return [self]
          def prepare
            scope.__send__(:memoized_methods).instance_variable_get(:@memory).delete(name)
            super()
          end

        private

          # Memoizer node for mutant
          #
          # @param [Parser::AST::Node] mutant
          #
          # @return [Parser::AST::Node]
          def wrap_node(mutant)
            s(:begin, mutant, s(:send, nil, :memoize, s(:args, s(:sym, name))))
          end

        end # Memoized
      end # Instance
    end # Method
  end # Subject
end # Mutant
