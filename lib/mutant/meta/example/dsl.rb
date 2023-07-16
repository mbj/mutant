# frozen_string_literal: true

module Mutant
  module Meta
    class Example
      # Example DSL
      class DSL
        include AST::Sexp

        # Run DSL on block
        #
        # @param [Thread::Backtrace::Location] location
        # @param [Set<Symbol>] types
        # @param [Mutation::Operators] operators
        #
        # @return [Example]
        #
        def self.call(location:, types:, operators:, block:) # rubocop:disable Metrics/ParameterLists
          instance = new(location, types, operators)
          instance.instance_eval(&block)
          instance.example
        end
        private_class_method :new

        # Initialize object
        #
        # @return [undefined]
        def initialize(location, types, operators)
          @expected  = []
          @location  = location
          @lvars     = []
          @operators = operators
          @types     = types
        end

        # Example captured by DSL
        #
        # @return [Example]
        #
        # @raise [RuntimeError]
        #   in case the example cannot be built
        def example
          fail 'source not defined' unless @source

          Example.new(
            expected:        @expected,
            location:        @location,
            lvars:           @lvars,
            node:            @node,
            operators:       @operators,
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
        end

        def regexp_mutations
          mutation('//')
          mutation('/nomatch\A/')
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
