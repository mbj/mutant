module Mutant
  class Runner
    # Runner for object config
    class Config < self

      # The expected coverage precision
      COVERAGE_PRECISION = 1

      register Mutant::Config

      # Run runner for object
      #
      # @param [Config] config
      # @param [Object] object
      #
      # @return [Runner]
      #
      # @api private
      #
      def self.run(config)
        handler = lookup(config.class)
        handler.new(config)
      end

      # Return subject runners
      #
      # @return [Enumerable<Runner::Subject>]
      #
      # @api private
      #
      attr_reader :subjects

      # Return failed subjects
      #
      # @return [Enumerable<Subject>]
      #
      # @api private
      #
      def failed_subjects
        subjects.reject(&:success?)
      end
      memoize :failed_subjects

      # Test if run was successful
      #
      # @return [true]
      #   if run was successful
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def success?
        coverage.round(COVERAGE_PRECISION) == config.expected_coverage.round(COVERAGE_PRECISION)
      end
      memoize :success?

      # Return strategy
      #
      # @return [Strategy]
      #
      # @api private
      #
      def strategy
        config.strategy
      end

      # Return coverage
      #
      # @return [Float]
      #
      # @api private
      #
      def coverage
        return 0.0 if amount_mutations.zero? && amount_kills.zero?
        (amount_kills.to_f / amount_mutations) * 100
      end
      memoize :coverage

      # Return amount of kills
      #
      # @return [Fixnum]
      #
      # @api private
      #
      def amount_kills
        mutations.select(&:success?).length
      end
      memoize :amount_kills

      # Return mutations
      #
      # @return [Array<Mutation>]
      #
      # @api private
      #
      def mutations
        subjects.map(&:mutations).flatten
      end
      memoize :mutations

      # Return amount of mutations
      #
      # @return [Fixnum]
      #
      # @api private
      #
      def amount_mutations
        mutations.length
      end

    private

      # Run config
      #
      # @return [undefined]
      #
      # @api private
      #
      def run_subjects
        strategy = self.strategy
        strategy.setup
        @subjects = visit_collection(config.subjects)
        strategy.teardown
      end

      # Run with strategy management
      #
      # @return [undefined]
      #
      # @api private
      #
      def run
        run_subjects
        @end = Time.now
        reporter.report(self)
      end

    end # Config
  end # Runner
end # Mutant
