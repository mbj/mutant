# encoding: utf-8

module Mutant

  # Abstract base class for killing strategies
  class Strategy
    include AbstractType, Adamantium::Flat, Equalizer.new

    REGISTRY = {}

    # Lookup strategy for name
    #
    # @param [String] name
    #
    # @return [Strategy]
    #   if found
    #
    # @api private
    #
    def self.lookup(name)
      REGISTRY.fetch(name)
    end

    # Register strategy
    #
    # @param [String] name
    #
    # @return [undefined]
    #
    # @api private
    #
    def self.register(name)
      REGISTRY[name] = self
    end
    private_class_method :register

    # Perform strategy setup
    #
    # @return [self]
    #
    # @api private
    #
    def setup
      self
    end

    # Perform strategy teardown
    #
    # @return [self]
    #
    # @api private
    #
    def teardown
      self
    end

    # Return all available tests by strategy
    #
    # @return [Enumerable<Test>]
    #
    # @api private
    #
    abstract_method :all_tests

    # Return tests for mutation
    #
    # TODO: This logic is now centralized but still fucked.
    #
    # @param [Mutation] mutation
    #
    # @return [Enumerable<Test>]
    #
    # @api private
    #
    def tests(subject)
      subject.match_prefixes.map do |match_expression|
        tests = all_tests.select do |test|
          test.subject_identification.start_with?(match_expression)
        end
        return tests if tests.any?
      end

      EMPTY_ARRAY
    end

    # Null strategy that never kills a mutation
    class Null < self

      register('null')

      # Return all tests
      #
      # @return [Enumerable<Test>]
      #
      # @api private
      #
      def all_tests
        EMPTY_ARRAY
      end

    end # Null

  end # Strategy
end # Mutant
