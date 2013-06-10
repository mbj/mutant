module Mutant
  class Mutator
    class Node
      # Abstract mutator for literal AST nodes
      class Literal < self
        include AbstractType

      private

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
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def nan
          zero_float = new_float(0)
          new_send_with_arguments(zero_float, :/, zero_float)
        end

        # Return AST representing negative infinity
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def negative_infinity
          new_send_with_arguments(new_float(-1), :/, new_float(0))
        end

        # Return AST representing infinity
        #
        # @return [Parser::AST::Node]
        #
        # @api private
        #
        def infinity
          new_send_with_arguments(new_float(1), :/, new_float(0))
        end

      end # Literal
    end # Node
  end # Mutator
end # Mutant
