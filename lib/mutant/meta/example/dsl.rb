# frozen_string_literal: true

module Mutant
  module Meta
    class Example
      # Example DSL
      class DSL
        include AST::Sexp

        # Run DSL on block
        #
        # @param [Pathname] file
        # @param [Set<Symbol>] types
        #
        # @return [Example]
        def self.call(file, types, block)
          instance = new(file, types)
          instance.instance_eval(&block)
          instance.example
        end

        private_class_method :new

        # Initialize object
        #
        # @return [undefined]
        def initialize(file, types)
          @file     = file
          @types    = types
          @node     = nil
          @expected = []
        end

        # Example captured by DSL
        #
        # @return [Example]
        #
        # @raise [RuntimeError]
        #   in case example cannot be build
        def example
          fail 'source not defined' unless @node
          Example.new(
            file:     @file,
            node:     @node,
            types:    @types,
            expected: @expected
          )
        end

      private

        # Set original source
        #
        # @param [String,Parser::AST::Node] input
        #
        # @return [undefined]
        def source(input)
          fail 'source already defined' if @node
          @node = node(input)
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

        # Add regexp mutations
        #
        # @return [undefined]
        def regexp_mutations
          mutation('//')
          mutation('/nomatch\A/')
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
            Unparser::Preprocessor.run(Unparser.parse(input))
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
