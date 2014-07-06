module Mutant
  class Reporter
    class CLI
      class Progress
        # Progress printer for configuration
        class Env < self

          handle Mutant::Env

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
            visit(config)
            info 'Available Subjects: %d', object.matchable_scopes.length
            info 'Subjects:           %d', object.subjects.length
          end

        end # Progress
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
