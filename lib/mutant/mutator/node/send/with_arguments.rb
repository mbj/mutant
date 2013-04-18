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

            if binary_operator?
              run(BinaryOperatorMethod)
              return
            end

            emit_send_remove_mutation
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
            emit_attribute_mutations(:arguments) do |mutation|
              if mutation.arguments.array.empty?
                mutation = new_send(receiver, node.name)
                mutation.privately = node.privately
                mutation
              else
                mutation
              end
            end
          end

          # Emit send remove mutation
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_send_remove_mutation
            array = node.arguments.array
            return unless array.length == 1
            emit(array.first)
          end
        end

      end
    end
  end
end
