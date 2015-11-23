module Mutant

  # Abstract base class mutant test framework integrations
  class Integration
    include AbstractType, Adamantium::Flat, Concord.new(:config)

    REGISTRY = {}

    # Setup integration
    #
    # @param [String] name
    #
    # @return [Integration]
    def self.setup(name)
      require "mutant/integration/#{name}"
      lookup(name)
    end

    # Lookup integration for name
    #
    # @param [String] name
    #
    # @return [Integration]
    #   if found
    def self.lookup(name)
      REGISTRY.fetch(name)
    end

    # Register integration
    #
    # @param [String] name
    #
    # @return [undefined]
    def self.register(name)
      REGISTRY[name] = self
    end
    private_class_method :register

    # Perform integration setup
    #
    # @return [self]
    def setup
      self
    end

    # Run a collection of tests
    #
    # @param [Enumerable<Test>] tests
    #
    # @return [Result::Test]
    abstract_method :call

    # Available tests for integration
    #
    # @return [Enumerable<Test>]
    abstract_method :all_tests

  private

    # Expression parser
    #
    # @return [Expression::Parser]
    def expression_parser
      config.expression_parser
    end

    # Null integration that never kills a mutation
    class Null < self

      register('null')

      # Available tests for integration
      #
      # @return [Enumerable<Test>]
      def all_tests
        EMPTY_ARRAY
      end

      # Run a collection of tests
      #
      # @param [Enumerable<Mutant::Test>] tests
      #
      # @return [Result::Test]
      def call(tests)
        Result::Test.new(
          output:  '',
          passed:  true,
          runtime: 0.0,
          tests:   tests
        )
      end

    end # Null

  end # Integration
end # Mutant
