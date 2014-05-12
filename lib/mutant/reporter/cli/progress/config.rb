module Mutant
  class Reporter
    class CLI
      class Progress
        # Progress printer for configuration
        class Config < self

          handle(Mutant::Config)

          delegate :matcher, :strategy, :expected_coverage

          # Report configuration
          #
          # @param [Mutant::Config] config
          #
          # @return [self]
          #
          # @api private
          #
          def run
            info 'Mutant configuration:'
            info 'Matcher:         %s',     matcher.inspect
            info 'Strategy:        %s',     strategy.inspect
            info 'Expect Coverage: %02f%%', expected_coverage.inspect
            self
          end

        end # Progress
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
