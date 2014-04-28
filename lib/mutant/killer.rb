# encoding: utf-8

module Mutant
  # Mutation killer
  class Killer
    include Adamantium::Flat
    include Anima.new(:test, :mutation)

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

    # Return test report
    #
    # @return [Test]
    #
    # @api private
    #
    def run
      mutation.insert
      report = test.run
      Report.new(
        killer: self,
        test_report: report
      )
    end

    # pid = fork do
    #   killer = @killer.new(strategy, mutation)
    #   exit(killer.killed? ? CLI::EXIT_SUCCESS : CLI::EXIT_FAILURE)
    # end

    # status = Process.wait2(pid).last
    # status.exited? && status.success?

  private

    # Return subject
    #
    # @return [Subject]
    #
    # @api private
    #
    def subject
      mutation.subject
    end

    # Null killer that never kills a mutation
    class Null < self

    private

      # Run killer
      #
      # @return [true]
      #   when mutant was killed
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def run
        false
      end

    end # Null
  end # Killer
end # Mutant
