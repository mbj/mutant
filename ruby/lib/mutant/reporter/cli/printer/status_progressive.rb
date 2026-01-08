# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        # Reporter for progressive output format on scheduler Status objects
        class StatusProgressive < self
          PIPE_FORMAT    = 'progress: %02d/%02d alive: %d runtime: %0.02fs killtime: %0.02fs mutations/s: %0.02f'
          TTY_BAR_WIDTH  = 24

          delegate(
            :amount_mutation_results,
            :amount_mutations,
            :amount_mutations_alive,
            :amount_mutations_killed,
            :killtime,
            :runtime
          )

          # Run printer
          #
          # @return [undefined]
          def run
            if tty?
              render_tty
            else
              render_pipe
            end
          end

        private

          def object
            super.payload
          end

          def mutations_per_second
            amount_mutation_results / runtime
          end

          def render_pipe
            status(
              PIPE_FORMAT,
              amount_mutation_results,
              amount_mutations,
              amount_mutations_alive,
              runtime,
              killtime,
              mutations_per_second
            )
          end

          def render_tty
            bar = ProgressBar.build(
              current: amount_mutation_results,
              total:   amount_mutations,
              width:   TTY_BAR_WIDTH
            )

            line = format_progress_line(bar)
            output.write(colorize(status_color, line))
          end

          def format_progress_line(bar)
            format(
              '%s %d/%d (%5.1f%%) %s alive: %d %0.1fs %0.2f/s',
              progress_prefix,
              amount_mutation_results,
              amount_mutations,
              bar.percentage,
              bar.render,
              amount_mutations_alive,
              runtime,
              mutations_per_second
            )
          end

          def progress_prefix
            'RUNNING'
          end
        end # StatusProgressive
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
