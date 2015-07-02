module Mutant
  class Reporter
    class CLI
      class Printer
        # Env progress printer
        class EnvProgress < self
          delegate(
            :coverage,
            :amount_subjects,
            :amount_mutations,
            :amount_mutations_alive,
            :amount_mutations_killed,
            :runtime,
            :killtime,
            :overhead,
            :env
          )

          # Run printer
          #
          # @return [undefined]
          #
          # rubocop:disable AbcSize
          #
          # @api private
          def run
            visit(Config, env.config)
            info 'Subjects:        %s',        amount_subjects
            info 'Mutations:       %s',        amount_mutations
            info 'Kills:           %s',        amount_mutations_killed
            info 'Alive:           %s',        amount_mutations_alive
            info 'Runtime:         %0.2fs',    runtime
            info 'Killtime:        %0.2fs',    killtime
            info 'Overhead:        %0.2f%%',   overhead_percent
            status 'Coverage:        %0.2f%%', coverage_percent
            status 'Expected:        %0.2f%%', (env.config.expected_coverage * 100)
          end

        private

          # Return coverage percent
          #
          # @return [Float]
          #
          # @api private
          def coverage_percent
            coverage * 100
          end

          # Return overhead percent
          #
          # @return [Float]
          #
          # @api private
          def overhead_percent
            (overhead / killtime) * 100
          end
        end # EnvProgress
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
