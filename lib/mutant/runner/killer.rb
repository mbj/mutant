module Mutant
  class Runner
    # Killer runner
    class Killer < self
      include Equalizer.new(:config, :killer)

      register Mutant::Killer

      # Return killer
      #
      # @return [Killer]
      #
      # @api private
      #
      attr_reader :killer
      protected :killer

      # Return kill report
      #
      # @return [Killer::Report]
      #
      # @api private
      #
      attr_reader :report

      # Test if killer ran successfully
      #
      # @return [Boolean]
      #
      # @api private
      def success?
        @report.success?
      end

      # Initialize object
      #
      # @param [Config] config
      # @param [Mutation] mutation
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(config, killer)
        @killer = killer
        super(config)
      end

      # Run killer
      #
      # @api private
      #
      def run
        @report = killer.run
      end

    end # Killer
  end # Runner
end # Mutant
