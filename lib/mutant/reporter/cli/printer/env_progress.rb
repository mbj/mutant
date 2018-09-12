# frozen_string_literal: true

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
            :amount_mutation_results,
            :runtime,
            :killtime,
            :overhead,
            :env
          )

          FORMATS = IceNine.deep_freeze([
            [:info,   'Subjects:        %s',      :amount_subjects          ],
            [:info,   'Mutations:       %s',      :amount_mutations         ],
            [:info,   'Results:         %s',      :amount_mutation_results  ],
            [:info,   'Kills:           %s',      :amount_mutations_killed  ],
            [:info,   'Alive:           %s',      :amount_mutations_alive   ],
            [:info,   'Runtime:         %0.2fs',  :runtime                  ],
            [:info,   'Killtime:        %0.2fs',  :killtime                 ],
            [:info,   'Overhead:        %0.2f%%', :overhead_percent         ],
            [:info,   'Mutations/s:     %0.2f',   :mutations_per_second     ],
            [:status, 'Coverage:        %0.2f%%', :coverage_percent         ]
          ])

          # Run printer
          #
          # @return [undefined]
          def run
            visit(Config, env.config)
            FORMATS.each do |report, format, value|
              __send__(report, format, __send__(value))
            end
          end

        private

          # Mutations processed per second
          #
          # @return [Float]
          #
          # @api private
          def mutations_per_second
            amount_mutation_results / runtime
          end

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
