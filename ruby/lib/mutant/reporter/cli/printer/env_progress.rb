# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        # Env progress printer
        class EnvProgress < self
          delegate(
            :amount_mutation_results,
            :amount_mutations_alive,
            :amount_mutations_killed,
            :amount_timeouts,
            :coverage,
            :env,
            :killtime,
            :runtime
          )

          FORMATS = [
            [:info,   'Results:         %s',      :amount_mutation_results],
            [:info,   'Kills:           %s',      :amount_mutations_killed],
            [:info,   'Alive:           %s',      :amount_mutations_alive ],
            [:info,   'Timeouts:        %s',      :amount_timeouts        ],
            [:info,   'Runtime:         %0.2fs',  :runtime                ],
            [:info,   'Killtime:        %0.2fs',  :killtime               ],
            [:info,   'Efficiency:      %0.2f%%', :efficiency_percent     ],
            [:info,   'Mutations/s:     %0.2f',   :mutations_per_second   ],
            [:status, 'Coverage:        %0.2f%%', :coverage_percent       ]
          ].each(&:freeze)

          # Run printer
          #
          # @return [undefined]
          def run
            visit(Env, env)
            FORMATS.each do |report, format, value|
              __send__(report, format, __send__(value))
            end
          end

        private

          def mutations_per_second
            amount_mutation_results / runtime
          end

          def coverage_percent
            # Floor to 2 decimal places to prevent rounding up to 100%
            # when there are surviving mutations
            (coverage * 10_000).floor / 100.0
          end

          def efficiency_percent
            (killtime / runtime) * 100
          end
        end # EnvProgress
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
