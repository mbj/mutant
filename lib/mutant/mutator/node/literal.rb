module Mutant
  class Mutator
    class Node
      # Abstract mutator for literal AST nodes
      class Literal < self
        include AbstractType

      private

        # Return new float literal
        #
        # @param [#to_f] value
        #
        # @return [Rubinius::Node::FloatLiteral]
        #
        # @api private
        #
        def new_float(value)
          new(Rubinius::AST::FloatLiteral, value)
        end

        # Emit a new node with wrapping class for each entry in values
        #
        # @param [Array] values
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_values(values)
          values.each do |value|
            emit_self(value)
          end
        end

        # Return AST representing NaN
        #
        # @return [Rubinius::Node::AST]
        #
        # @api private
        #
        def nan
          zero_float = new_float(0)
          new_send_with_arguments(zero_float, :/, zero_float)
        end

        # Return AST representing negative infinity
        #
        # @return [Rubinius::Node::AST]
        #
        # @api private
        #
        def negative_infinity
          new_send_with_arguments(new_float(-1), :/, new_float(0))
        end

        # Return AST representing infinity
        #
        # @return [Rubinius::Node::AST]
        #
        # @api private
        #
        def infinity
          new_send_with_arguments(new_float(1), :/, new_float(0))
        end
      end
    end
  end
end
