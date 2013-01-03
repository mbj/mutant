module Mutant
  class Mutator
    class Node
      # Mutator that does not do mutations on ast
      class Noop < self

        # Literal references to self do not need to be mutated?
        handle(Rubinius::AST::Self)

        # Currently unhandled node classes. Feel free to contribute your mutator!
        handle(Rubinius::AST::ElementAssignment)
        handle(Rubinius::AST::AttributeAssignment)
        handle(Rubinius::AST::Not)
        handle(Rubinius::AST::And)
        handle(Rubinius::AST::Or)
        handle(Rubinius::AST::Defined)
        handle(Rubinius::AST::Super)
        handle(Rubinius::AST::Next)
        handle(Rubinius::AST::Break)
        handle(Rubinius::AST::Match3)
        handle(Rubinius::AST::ZSuper)
        handle(Rubinius::AST::MultipleAssignment)
        handle(Rubinius::AST::ScopedConstant)
        handle(Rubinius::AST::LocalVariableAccess)
        handle(Rubinius::AST::InstanceVariableAccess)
        handle(Rubinius::AST::GlobalVariableAccess)
        handle(Rubinius::AST::ClassVariableAccess)
        handle(Rubinius::AST::ToplevelConstant)
        handle(Rubinius::AST::Ensure)
        handle(Rubinius::AST::Rescue)
        handle(Rubinius::AST::DynamicString)
        handle(Rubinius::AST::DynamicSymbol)
        handle(Rubinius::AST::DynamicRegex)
        handle(Rubinius::AST::File)
        handle(Rubinius::AST::OpAssignOr19)
        handle(Rubinius::AST::BlockPass19)
        handle(Rubinius::AST::OpAssign1)
        handle(Rubinius::AST::OpAssign2)
        handle(Rubinius::AST::ConstantAccess)
        handle(Rubinius::AST::Yield)
        handle(Rubinius::AST::Begin)
        handle(Rubinius::AST::Rescue)
      
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
