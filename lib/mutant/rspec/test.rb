module Mutant
  module Rspec
    # Rspec test abstraction
    class Test < Mutant::Test
      include Concord.new(:strategy, :example_group)

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
        flag = example_group.run(strategy.reporter)
        Report.new(
          test: self,
          output: '',
          success: flag
        )
      end

    end # Test
  end # Rspec
end # Mutant
