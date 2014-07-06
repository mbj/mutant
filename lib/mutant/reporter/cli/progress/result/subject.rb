module Mutant
  class Reporter
    class CLI
      class Progress
        class Result
          # Reporter for subject runners
          class Subject < self

            FORMAT = '(%02d/%02d) %3d%% - killtime: %0.02fs runtime: %0.02fs overhead: %0.02fs'.freeze

            handle(Mutant::Result::Subject)

            # Run printer
            #
            # @return [self]
            #
            # @api private
            #
            def run
              print_progress_bar_finish
              print_stats
              self
            end

            delegate :coverage, :runtime, :amount_mutations_killed, :amount_mutations, :killtime, :overhead

          private

            # Print stats
            #
            # @return [undefined]
            #
            # @api private
            #
            def print_stats
              status(FORMAT, amount_mutations_killed, amount_mutations, coverage * 100, killtime, runtime, overhead)
            end

            # Print progress bar finish
            #
            # @return [undefined]
            #
            # @api private
            #
            def print_progress_bar_finish
              puts unless amount_mutations.zero?
            end

          end # Subject
        end # Result
      end # Progress
    end  # CLI
  end # Reporter
end # Mutant
