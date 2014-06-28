module Mutant
  module Rspec
    # Rspec test abstraction
    class Test < Mutant::Test
      include Anima.new(:strategy, :example_group, :expression)

      private :strategy

      PREFIX = :rspec

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
  end # Rspec
end # Mutant
