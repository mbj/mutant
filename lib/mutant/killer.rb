module Mutant
  # Mutation killer
  class Killer
    include Adamantium::Flat, Anima.new(:test, :mutation)

    # Report object for kill results
    class Report
      include Anima.new(
        :killer,
        :test_report
      )

      # Test if kill was successful
      #
      # @return [Boolean]
      #
      # @api private
      #
      def success?
        killer.mutation.should_fail?.equal?(test_report.failed?)
      end

    end # Report

    # Return killer report
    #
    # @return [Killer::Report]
    #
    # @api private
    #
    def run

      Report.new(
        killer:      self,
        test_report: test_report.update(test: test)
      )
    end

    # Return test report
    #
    # @return [Test::Report]
    #
    # @api private
    #
    def test_report
      Isolation.call do
        mutation.insert
        test.run
      end
    rescue Exception => exception
      Test::Report.new(
        test: test,
        output: exception.message,
        success: true
      )
    end

  end # Killer
end # Mutant
