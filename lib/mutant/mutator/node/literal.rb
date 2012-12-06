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

        # Return AST representing NaN
        #
        # @return [Rubinius::Node::AST]
        #
        # @api private
        #
        def nan
          new_send(new_float(0), :/, new_float(0))
        end

        # Return AST representing negative infinity
        #
        # @return [Rubinius::Node::AST]
        #
        # @api private
        #
        def negative_infinity
          new(Rubinius::AST::Negate, infinity)
        end

        # Return AST representing infinity
        #
        # @return [Rubinius::Node::AST]
        #
        # @api private
        #
        def infinity
          new_send(new_float(1), :/, new_float(0))
        end
      end
    end
  end
end
