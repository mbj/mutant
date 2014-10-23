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

    # Kill mutation with test under isolation
    #
    # @param [Isolation] isolation
    # @param [Mutation] mutation
    #
    # @return [Report::Test]
    #
    # @api private
    #
    def kill(isolation, mutation)
      time = Time.now
      isolation.call do
        mutation.insert
        run
      end.update(test: self)
    rescue Isolation::Error => exception
      Result::Test.new(
        test:     self,
        mutation: mutation,
        runtime:  Time.now - time,
        output:   exception.message,
        passed:   false
      )
    end

  private

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
