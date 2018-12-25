# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        # Reporter for subject progress
        class SubjectProgress < self
          FORMAT = '(%02d/%02d) %3d%% - killtime: %0.02fs runtime: %0.02fs overhead: %0.02fs'

          delegate(
            :tests,
            :subject,
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
            puts("#{subject.identification} mutations: #{amount_mutations}")
            print_mutation_results
            print_progress_bar_finish
            print_stats
          end

        private

          # Print stats
          #
          # @return [undefined]
          def print_stats
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

          # Print progress bar finish
          #
          # @return [undefined]
          def print_progress_bar_finish
            puts(nil) unless amount_mutation_results.zero?
          end

          # Print mutation results
          #
          # @return [undefined]
          def print_mutation_results
            visit_collection(MutationProgressResult, object.mutation_results)
          end
        end # SubjectProgress
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
