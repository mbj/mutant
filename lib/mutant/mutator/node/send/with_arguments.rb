module Mutant
  class Mutator
    class Node
      class Send

        # Mutator for send with arguments
        class WithArguments < self
          
          handle(Rubinius::AST::SendWithArguments)

        private

          # Emit mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            super
            emit_call_remove_mutation
            emit_argument_mutations
          end

          # Test if message is a binary operator
          #
          # @return [true]
          #   if message is a binary operator
          #
          # @return [false]
          #   otherwise
          #
          # @api private
          #
          def binary_operator?
            Mutant::BINARY_METHOD_OPERATORS.include?(node.name)
          end

          # Emit argument mutations
          #
          # @api private
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_argument_mutations
            if binary_operator?
              run(BinaryOperatorMethod)
              return
            end

            emit_attribute_mutations(:arguments)
          end

          # Emit transfomr call mutation
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_call_remove_mutation
            array = node.arguments.array
            return unless array.length == 1
            emit(array.first)
          end
        end

      end
    end
  end
end
