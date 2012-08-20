module Mutant
  class Mutator
    # Mutator that does do not mutations on ast
    class Noop < self

      # Literal references to self do not need to be mutated. 
      handle(Rubinius::AST::Self)
      handle(Rubinius::AST::NilLiteral)
      handle(Rubinius::AST::Return)
      handle(Rubinius::AST::ElementAssignment)
      handle(Rubinius::AST::AttributeAssignment)
      handle(Rubinius::AST::Not)
      handle(Rubinius::AST::LocalVariableAssignment)
      handle(Rubinius::AST::LocalVariableAccess)
      handle(Rubinius::AST::InstanceVariableAssignment)
      handle(Rubinius::AST::InstanceVariableAccess)
      handle(Rubinius::AST::GlobalVariableAssignment)
      handle(Rubinius::AST::GlobalVariableAccess)
      handle(Rubinius::AST::Ensure)
      handle(Rubinius::AST::Rescue)
      handle(Rubinius::AST::DynamicString)
      handle(Rubinius::AST::DynamicSymbol)
      handle(Rubinius::AST::DynamicRegex)
    
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
