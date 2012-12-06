module Mutant
  class Mutator
    class Literal
      # Mutator for hash literals
      class Hash < self

        handle(Rubinius::AST::HashLiteral)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_nil
          emit_values(values)
          emit_element_presence
          emit_body(array)
        end

        # Return array of values in literal
        #
        # @return [Array]
        #
        # @api private
        #
        def array
          node.array
        end

        # Return duplicate of array values in literal
        #
        # @return [Array]
        #
        # @api private
        #
        def dup_array
          array.dup
        end

        # Return values to mutate against
        #
        # @return [Array]
        #
        # @api private
        #
        def values
          [[], dup_array << new_nil << new_nil ]
        end

        # Emit element presence mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_element_presence
          0.step(array.length-1, 2) do |index|
            contents = dup_array
            contents.delete_at(index)
            contents.delete_at(index)
            emit_self(contents)
          end
        end
      end
    end
  end
end
