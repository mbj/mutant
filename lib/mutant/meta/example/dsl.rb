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
          @expected = []
          @file     = file
          @lvars    = []
          @source   = nil
          @types    = types
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
            lvars:           @lvars,
            node:            @node,
            original_source: @source,
            types:           @types
          )
        end

        # Declare a local variable
        #
        # @param [Symbol]
        def declare_lvar(name)
          @lvars << name
        end

      private

        def source(input)
          fail 'source already defined' if @source

          @source = input
          @node   = node(input)
        end

        def mutation(input)
          expected = Expected.new(original_source: input, node: node(input))

          if @expected.include?(expected)
            fail "Mutation for input: #{input.inspect} is already expected"
          end

          @expected << expected
        end

        def singleton_mutations
          mutation('nil')
          mutation('self')
        end

        def node(input)
          case input
          when String
            parser.parse(Unparser.buffer(input))
          else
            fail "Unsupported input: #{input.inspect}"
          end
        end

        def parser
          Unparser.parser.tap do |parser|
            @lvars.each(&parser.static_env.public_method(:declare))
          end
        end
      end # DSL
    end # Example
  end # Meta
end # Mutant
