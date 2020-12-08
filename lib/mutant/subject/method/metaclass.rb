# frozen_string_literal: true

module Mutant
  class Subject
    class Method
      # Singleton method defined using metaclass syntax
      # (class << self; def foo; end; end)
      class Metaclass < self
        include AST::Sexp

        NAME_INDEX = 0
        SYMBOL     = '.'

        # Prepare subject for mutation insertion
        #
        # @return [self]
        def prepare
          scope.singleton_class.public_send(:undef_method, name)
          self
        end

      private

        def wrap_node(mutant)
          s(:sclass, AST::Nodes::N_SELF, mutant)
        end
      end # Metaclass
    end # Method
  end # Subject
end # Mutant
