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
          Example.new(
            expected:        @expected,
            file:            @file,
            node:            @node,
            original_source: @source,
            types:           @types
          )
        end

      private

        # rubocop:disable Metrics/MethodLength
        def source(input)
          fail 'source already defined' if @source

          case input
          when String
            @source = input
            @node   = Unparser::Preprocessor.run(Unparser.parse(input))
          when ::Parser::AST::Node
            @source = Unparser.unparse(input)
            @node   = input
          else
            fail "Unsupported input: #{input.inspect}"
          end
        end
        # rubocop:enable Metrics/MethodLength

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
