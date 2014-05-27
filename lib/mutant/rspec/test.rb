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
        metadata = example_group.metadata
        if strategy.rspec2?
          metadata.fetch(:example_group).fetch(:full_description)
        else
          metadata.fetch(:full_description)
        end
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
