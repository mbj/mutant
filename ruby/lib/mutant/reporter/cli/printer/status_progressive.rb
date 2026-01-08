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
            FORMAT         = '%s %d/%d (%5.1f%%) %s alive: %d %0.1fs %0.2f/s'
            MIN_BAR_WIDTH  = 10
            MAX_BAR_WIDTH  = 40
            PREFIX         = 'RUNNING'

            def run
              bar  = ProgressBar.build(current: amount_mutation_results, total: amount_mutations, width: bar_width)
              line = format(FORMAT, PREFIX, amount_mutation_results, amount_mutations, bar.percentage, bar.render, amount_mutations_alive, runtime, mutations_per_second)
              output.write(colorize(status_color, line))
            end

          private

            def bar_width
              non_bar_content = format(FORMAT, PREFIX, amount_mutation_results, amount_mutations, 99.9, '', amount_mutations_alive, runtime, mutations_per_second)
              available_width = output.terminal_width - non_bar_content.length

              available_width.clamp(MIN_BAR_WIDTH, MAX_BAR_WIDTH)
            end
          end # Tty
        end # StatusProgressive
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
