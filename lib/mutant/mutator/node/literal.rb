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

      end # Literal
    end # Node
  end # Mutator
end # Mutant
