module Mutant
  module Rspec
    # Rspec test abstraction
    class Test < Mutant::Test
      include Concord::Public.new(:strategy, :example_group)

      PREFIX = :rspec

      # Return subject identification
      #
      # @return [String]
      #
      # @api private
      #
      def subject_identification
        example_group.description
      end
      memoize :subject_identification

      # Run test, return report
      #
      # @return [String]
      #
      # @api private
      #
      def run
        strategy.run(self)
      end

    end # Test
  end # Rspec
end # Mutant
