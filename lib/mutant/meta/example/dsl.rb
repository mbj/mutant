module Mutant
  module Meta
    class Example
      # Example DSL
      class DSL
        include AST::Sexp

        # Run DSL on block
        #
        # @return [Example]
        def self.call(file, block)
          instance = new(file)
          instance.instance_eval(&block)
          instance.example
        end

        private_class_method :new

        # Initialize object
        #
        # @return [undefined]
        def initialize(file)
          @file     = file
          @source   = nil
          @expected = []
        end

        # Example captured by DSL
        #
        # @return [Example]
        #
        # @raise [RuntimeError]
        #   in case example cannot be build
        def example
          fail 'source not defined' unless @source
          Example.new(@file, @source, @expected)
        end

      private

        # Set original source
        #
        # @param [String,Parser::AST::Node] input
        #
        # @return [undefined]
        def source(input)
          fail 'source already defined' if @source
          @source = node(input)
        end

        # Add expected mutation
        #
        # @param [String,Parser::AST::Node] input
        #
        # @return [undefined]
        def mutation(input)
          node = node(input)
          if @expected.include?(node)
            fail "Mutation for input: #{input.inspect} is already expected"
          end
          @expected << node
        end

        # Add singleton mutations
        #
        # @return [undefined]
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
        def node(input)
          case input
          when String
            Unparser::Preprocessor.run(::Parser::CurrentRuby.parse(input))
          when ::Parser::AST::Node
            input
          else
            fail "Cannot coerce to node: #{input.inspect}"
          end
        end

      end # DSL
    end # Example
  end # Meta
end # Mutant
