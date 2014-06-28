module Mutant
  # Abstract base class for test that might kill a mutation
  class Test
    include Adamantium::Flat, Concord::Public.new(:strategy, :expression)

    # Return test identification
    #
    # @return [String]
    #
    # @api private
    #
    def identification
      "#{strategy.name}:#{expression.syntax}"
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

  end # Test
end # Mutant
