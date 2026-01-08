# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        # Base class for progressive status output
        class StatusProgressive < self
          delegate(
            :amount_mutation_results,
            :amount_mutations,
            :amount_mutations_alive,
            :amount_mutations_killed,
            :killtime,
            :runtime
          )

        private

          def object
            super.payload
          end

          def mutations_per_second
            amount_mutation_results / runtime
          end

          # Pipe output format (non-TTY)
          class Pipe < StatusProgressive
            FORMAT = 'progress: %02d/%02d alive: %d runtime: %0.02fs killtime: %0.02fs mutations/s: %0.02f'

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
          end # Pipe

          # TTY output format with progress bar
          class Tty < StatusProgressive
            FORMAT              = '%s %d/%d (%5.1f%%) %s alive: %d %0.1fs %0.2f/s'
            MAX_BAR_WIDTH       = 40
            PREFIX              = 'RUNNING'
            PERCENTAGE_ESTIMATE = 99.9

            def run
              bar  = ProgressBar.build(current: amount_mutation_results, total: amount_mutations, width: bar_width)
              line = FORMAT % format_args(bar.percentage, bar.render)
              output.write(colorize(status_color, line))
            end

          private

            def format_args(percentage, bar)
              [PREFIX, amount_mutation_results, amount_mutations, percentage, bar,
               amount_mutations_alive, runtime, mutations_per_second]
            end

            def bar_width
              non_bar_content = FORMAT % format_args(PERCENTAGE_ESTIMATE, nil)
              available_width = output.terminal_width - non_bar_content.length
              available_width.clamp(0, MAX_BAR_WIDTH)
            end
          end # Tty
        end # StatusProgressive
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
