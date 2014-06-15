module Mutant
  class Reporter
    class CLI
      class Progress
        # Progress printer for configuration
        class Config < self

          handle(Mutant::Runner::Config)

          delegate :config

          # Report configuration
          #
          # @param [Mutant::Config] config
          #
          # @return [self]
          #
          # @api private
          #
          def run
            if running?
              info 'Mutant configuration:'
              info 'Matcher:         %s',      config.matcher.inspect
              info 'Strategy:        %s',      config.strategy.inspect
              info 'Expect Coverage: %0.2f%%', config.expected_coverage.inspect
            end
            self
          end

        end # Progress
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
