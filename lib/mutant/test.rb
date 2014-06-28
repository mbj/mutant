module Mutant
  # Abstract base class for test that might kill a mutation
  class Test
    include Adamantium::Flat, Concord::Public.new(:integration, :expression)

    # Return test identification
    #
    # @return [String]
    #
    # @api private
    #
    def identification
      "#{integration.name}:#{expression.syntax}"
    end
    memoize :identification

    # Run test, return report
    #
    # @return [Report]
    #
    # @api private
    #
    def run
      integration.run(self)
    end

  end # Test
end # Mutant
