# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        # Printer for mutation config
        class Config < self

          # Report configuration
          #
          # @param [Mutant::Config] config
          #
          # @return [undefined]
          #
          # rubocop:disable Metrics/AbcSize
          def run
            info 'Usage:           %s',    object.usage.value
            info 'Matcher:         %s',    object.matcher.inspect
            info 'Integration:     %s',    object.integration.name || 'null'
            info 'Jobs:            %s',    object.jobs || 'auto'
            info 'Includes:        %s',    object.includes
            info 'Requires:        %s',    object.requires
            info 'Operators:       %s',    object.mutation.operators.class.operators_name
            info 'MutationTimeout: %0.9g', object.mutation.timeout if object.mutation.timeout
          end
          # rubocop:enable Metrics/AbcSize

        end # Config
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
