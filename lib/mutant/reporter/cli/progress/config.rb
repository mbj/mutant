module Mutant
  class Reporter
    class CLI
      class Progress
        # Progress printer for configuration
        class Config < self

          handle(Mutant::Config)

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
            info 'Matcher:            %s',      object.matcher_config.inspect
            info 'Integration:        %s',      object.integration.name
            info 'Expect Coverage:    %0.2f%%', object.expected_coverage.inspect
            self
          end

        end # Progress
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
