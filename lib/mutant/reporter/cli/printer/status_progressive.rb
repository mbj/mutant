# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        # Reporter for progressive output format on scheduler Status objects
        class StatusProgressive < self
          FORMAT = 'progress: %02d/%02d alive: %d runtime: %0.02fs killtime: %0.02fs mutations/s: %0.02f'

          delegate(
            :amount_mutation_results,
            :amount_mutations,
            :amount_mutations_alive,
            :amount_mutations_killed,
            :killtime,
            :overhead,
            :runtime
          )

          # Run printer
          #
          # @return [undefined]
          def run
            status(
              FORMAT,
              amount_mutation_results,
              amount_mutations,
              amount_mutations_alive,
              runtime,
              killtime,
              mutations_per_second
            )
          end

        private

          # Object being printed
          #
          # @return [Result::Env]
          def object
            super().payload
          end

          # Mutations processed per second
          #
          # @return [Float]
          #
          # @api private
          def mutations_per_second
            amount_mutation_results / runtime
          end
        end # StatusProgressive
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
