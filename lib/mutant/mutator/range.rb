module Mutant
  class Mutator
    # Mutator for range literal AST nodes
    class Range < Mutator
    private

      # Append mutations on range literals
      #
      # @param [#<<] generator
      #
      # @return [undefined]
      #
      # @api private
      #
      def mutants(generator)
        generator << new_nil
        generator << new(Rubinius::AST::RangeExclude,node.start,node.finish)
        generator << new_self(neg_infinity,node.finish)
        generator << new_self(nan,node.finish)
        generator << new_self(node.start,infinity)
        generator << new_self(node.start,nan)
      end

      # Return AST representing infinity
      #
      # @return [Rubinius::Node::AST]
      #
      # @api private
      #
      def neg_infinity
        '-1.0/0.0'.to_ast.tap do |call|
          call.line = node.line
        end
      end

      # Return AST representing infinity
      #
      # @return [Rubinius::Node::AST]
      #
      # @api private
      #
      def infinity
        '1.0/0.0'.to_ast.tap do |call|
          call.line = node.line
        end
      end

      # Return AST representing NaN
      #
      # @return [Rubinius::Node::AST]
      #
      # @api private
      #
      def nan
        '0.0/0.0'.to_ast.tap do |call|
          call.line = node.line
        end
      end
    end
  end
end
