module Mutant
  module Meta
    class Example

      # Example DSL
      class DSL
        include NodeHelpers

        # Run DSL on block
        #
        # @return [Example]
        #
        # @api private
        #
        def self.run(block)
          instance = new
          instance.instance_eval(&block)
          instance.example
        end

        # Initialize DSL context
        #
        # @return [undefined]
        #
        # @api private
        #
        def initialize
          @source = nil
          @expected = []
        end

        # Return example
        #
        # @return [Example]
        #
        # @raise [RuntimeError]
        #   in case example cannot be build
        #
        # @api private
        #
        def example
          raise 'source not defined' unless @source
          Example.new(@source, @expected)
        end

      private

        # Set original source
        #
        # @param [String,Parser::AST::Node] input
        #
        # @return [self]
        #
        # @api private
        #
        def source(input)
          raise 'source already defined' if @source
          @source = node(input)

          self
        end

        # Add expected mutation
        #
        # @param [String,Parser::AST::Node] input
        #
        # @return [self]
        #
        # @api private
        #
        def mutation(input)
          node = node(input)
          if @expected.include?(node)
            raise "Node for input: #{input.inspect} is already expected"
          end
          @expected << node

          self
        end

        # Add singleotn mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def singleton_mutations
          mutation('nil')
          mutation('self')
        end

        # Helper method to coerce input to node
        #
        # @param [String,Parser::AST::Node] input
        #
        # @return [Parser::AST::Node]
        #
        # @raise [RuntimeError]
        #   in case input cannot be coerced
        #
        # @api private
        #
        def node(input)
          case input
          when String
            Unparser::Preprocessor.run(Parser::CurrentRuby.parse(input))
          when Parser::AST::Node
            input
          else
            raise "Cannot coerce to node: #{source.inspect}"
          end
        end

      end # DSL
    end # Example
  end # Meta
end # Mutant
