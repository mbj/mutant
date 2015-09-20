module Mutant

  # Abstract base class mutant test framework integrations
  class Integration
    include AbstractType, Adamantium::Flat, Concord.new(:expression_parser)

    REGISTRY = {}

    # Setup integration
    #
    # @param [String] name
    #
    # @return [Integration]
    #
    # @api private
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
    #
    # @api private
    def self.lookup(name)
      REGISTRY.fetch(name)
    end

    # Register integration
    #
    # @param [String] name
    #
    # @return [undefined]
    #
    # @api private
    def self.register(name)
      REGISTRY[name] = self
    end
    private_class_method :register

    # Perform integration setup
    #
    # @return [self]
    #
    # @api private
    def setup
      self
    end

    # Run a collection of tests
    #
    # @param [Enumerable<Test>] tests
    #
    # @return [Result::Test]
    #
    # @api private
    abstract_method :call

    # Available tests for integration
    #
    # @return [Enumerable<Test>]
    #
    # @api private
    abstract_method :all_tests

    # Null integration that never kills a mutation
    class Null < self

      register('null')

      # Available tests for integration
      #
      # @return [Enumerable<Test>]
      #
      # @api private
      def all_tests
        EMPTY_ARRAY
      end

      # Run a collection of tests
      #
      # @param [Enumerable<Mutant::Test>] tests
      #
      # @return [Result::Test]
      #
      # @api private
      def call(tests)
        Result::Test.new(
          tests:   tests,
          output:  '',
          runtime: 0.0,
          passed:  true
        )
      end

    end # Null

  end # Integration
end # Mutant
