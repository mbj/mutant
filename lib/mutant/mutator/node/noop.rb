module Mutant
  class Mutator
    class Node
      # Mutator that does not do mutations on ast
      class Noop < self

        # Literal references to self do not need to be mutated?
        handle(Rubinius::AST::Self)

        # Currently unhandled node classes. Feel free to contribute your mutator!
        #
        # FIXME: This list is mixed with some 1.8 only nodes that should be extracted
        #
        %w(
          ZSuper
          ElementAssignment
          AttributeAssignment
          Not
          And
          Or
          Defined
          Super
          Next
          Break
          Match3
          ZSuper
          MultipleAssignment
          ScopedConstant
          LocalVariableAccess
          InstanceVariableAccess
          GlobalVariableAccess
          ClassVariableAccess
          ToplevelConstant
          Ensure
          Rescue
          DynamicString
          DynamicSymbol
          DynamicRegex
          File
          OpAssignOr19
          BlockPass19
          OpAssign1
          NthRef
          OpAssign2
          SplatValue
          ConstantAccess
          Yield
          Begin
          Rescue
        ).each do |name|
          handle(Rubinius::AST.const_get(name))
        end

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          # noop
        end
      end
    end
  end
end
