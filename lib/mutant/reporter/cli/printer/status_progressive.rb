# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        # Reporter for progressive output format on scheduler Status objects
        class StatusProgressive < self
          FORMAT = '(%02d/%02d) %3d%% - killtime: %0.02fs runtime: %0.02fs overhead: %0.02fs'

          delegate(
            :coverage,
            :runtime,
            :amount_mutations_killed,
            :amount_mutations,
            :amount_mutation_results,
            :killtime,
            :overhead
          )

          # Run printer
          #
          # @return [undefined]
          def run
            status(
              FORMAT,
              amount_mutations_killed,
              amount_mutations,
              coverage * 100,
              killtime,
              runtime,
              overhead
            )
          end

        private

          # Object being printed
          #
          # @return [Result::Env]
          def object
            super().payload
          end
        end # StatusProgressive
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
