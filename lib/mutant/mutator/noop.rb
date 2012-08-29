module Mutant
  class Mutator
    # Mutator that does not do mutations on ast
    class Noop < self

      # Literal references to self do not need to be mutated. 
      handle(Rubinius::AST::Self)
      handle(Rubinius::AST::NilLiteral)
      handle(Rubinius::AST::Return)
      handle(Rubinius::AST::ElementAssignment)
      handle(Rubinius::AST::AttributeAssignment)
      handle(Rubinius::AST::Not)
      handle(Rubinius::AST::And)
      handle(Rubinius::AST::Super)
      handle(Rubinius::AST::ZSuper)
      handle(Rubinius::AST::MultipleAssignment)
      handle(Rubinius::AST::ScopedConstant)
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
