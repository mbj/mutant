module Mutant
  # Abstract base class for test that might kill a mutation
  class Test
    include AbstractType, Adamantium::Flat

    # Run tests
    #
    # @return [Test::Result]
    #
    # @api private
    #
    abstract_method :run

    # Return test identification
    #
    # @return [String]
    #
    # @api private
    #
    def identification
      "#{self.class::PREFIX}:#{expression.syntax}"
    end
    memoize :identification

    # Run test, return report
    #
    # @return [Report]
    #
    # @api private
    #
    def run
      strategy.run(self)
    end

    # Return expression
    #
    # @return [Expression]
    #
    # @api private
    #
    abstract_method :expression

  end # Test
end # Mutant
