module Mutant
  class Mutator
    class Node

      class ZSuper < self

        handle(Rubinius::AST::ZSuper)

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_node(Rubinius::AST::Super, new(Rubinius::AST::ActualArguments))
        end

      end

      class Super < self
        handle(Rubinius::AST::Super)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_node(Rubinius::AST::ZSuper)
          emit_attribute_mutations(:arguments)
        end
      end
    end
  end
end
