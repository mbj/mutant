module Mutant
  class Mutator
    class Node
      # Mutator on AST blocks
      class Block < self

        handle(Rubinius::AST::Block)

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          array = input.array
          emit_attribute_mutations(:array)
        end

        # Test if node is new
        #
        # FIXME: Remove this hack and make sure empty bodies are not generated
        #
        # @param [Rubinius::AST::Node]
        #
        # @return [true]
        #   if node is new
        #
        # @return [false]
        #   otherwise
        #
        def new?(node)
          if node.array.empty?
            node.array << new_nil
          end

          super
        end
      end
    end
  end
end
