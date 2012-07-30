module Mutant
  class Mutator
    # Represent mutations on fixnum literal
    class FloatLiteral < Mutator
    private
      # Append mutants
      #
      # @param [#<<] generator
      #
      # @return [undefined]
      #
      def mutants(generator)
        generator << new_nil
        generator << new_self(0.0)
        generator << new_self(1.0)
        generator << new_self(-node.value)
        generator.generate do
          new_self(Mutant.random_float)
        end
        generator << infinity
        generator << neg_infinity
        generator << nan
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

      # Return AST representing negative Infinity
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
    end
  end
end
