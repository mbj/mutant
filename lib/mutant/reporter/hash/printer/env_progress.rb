module Mutant
  class Reporter
    class Hash
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
            {
              config: visit(Config, env.config),
              subjects: amount_subjects,
              mutations: amount_mutations,
              kills: amount_mutations_killed,
              alive: amount_mutations_alive,
              runtime: runtime,
              killtime: killtime,
              overhead: overhead_percent.to_f,
              coverage: coverage_percent.to_f,
              expected: (env.config.expected_coverage * 100).to_f
            }
          end

        private

          # Coverage in percent
          #
          # @return [Float]
          #
          # @api private
          def coverage_percent
            coverage * 100
          end

          # Overhead in percent
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
