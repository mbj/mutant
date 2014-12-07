module Mutant
  class Reporter
    class CLI
      class Printer
        class Progressive < self
          include AbstractType

          # Reporter for progressive output format on scheduler Status objects
          class TraceStatus < self

            FORMAT = 'Tracing (%03d/%03d) %3d%% - runtime: %0.02fs tracetime: %0.02fs overhead: %3d%'.freeze

            delegate(
              :runtime,
              :amount_test_traces,
              :amount_tests,
              :progress_percent,
              :runtime,
              :worktime,
              :overhead_percent
            )

            # Run printer
            #
            # @return [self]
            #
            # @api private
            #
            def run
              info(
                FORMAT,
                amount_test_traces,
                amount_tests,
                progress_percent,
                runtime,
                worktime,
                overhead_percent
              )

              self
            end

          private

            # Return object being printed
            #
            # @return [Result::Env]
            #
            # @api private
            #
            def object
              super().payload
            end
          end # TraceStatus

          # Reporter for progressive output format on scheduler Status objects
          class KillStatus < self

            FORMAT = 'Killing (%03d/%03d) %3d%% - coverage: %3d%% killtime: %0.02fs runtime: %0.02fs overhead: %3d%%'.freeze

            delegate(
              :amount_mutation_results,
              :amount_mutations,
              :progress_percent,
              :coverage_percent,
              :worktime,
              :runtime,
              :overhead_percent
            )

            # Run printer
            #
            # @return [self]
            #
            # @api private
            #
            def run
              status(
                FORMAT,
                amount_mutation_results,
                amount_mutations,
                progress_percent,
                coverage_percent,
                worktime,
                runtime,
                overhead_percent
              )

              self
            end

          private

            # Return object being printed
            #
            # @return [Result::Env]
            #
            # @api private
            #
            def object
              super().payload
            end
          end

        end # KillStatus
      end # Progressive
    end # Printer
  end # Reporter
end # Mutant
