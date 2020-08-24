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

        def source(input)
          fail 'source already defined' if @node
          @node = node(input)
        end

        def mutation(input)
          node = node(input)
          if @expected.include?(node)
            fail "Mutation for input: #{input.inspect} is already expected"
          end
          @expected << node
        end

        def singleton_mutations
          mutation('nil')
          mutation('self')
        end

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
