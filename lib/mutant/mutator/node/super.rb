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
          emit_without_block
          emit_attribute_mutations(:block) if node.block
          emit_attribute_mutations(:arguments) 
        end

        # Emit without block mutation
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_without_block
          dup = dup_node
          dup.block = nil
          emit(dup)
        end
      end
    end
  end
end
