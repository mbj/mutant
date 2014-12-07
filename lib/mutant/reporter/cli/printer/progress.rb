module Mutant
  class Reporter
    class CLI
      class Printer
        class Progress < self

          # Progress printer for mutations
          class Mutation < self

            SUCCESS = '.'.freeze
            FAILURE = 'F'.freeze

            # Run printer
            #
            # @return [self]
            #
            # @api private
            #
            def run
              char(success? ? SUCCESS : FAILURE)
            end

          private

            # Write colorized char
            #
            # @param [String] char
            #
            # @return [undefined]
            #
            # @api private
            #
            def char(char)
              output.write(colorize(status_color, char))
            end

          end # Progress printer for mutations

          # Progress printer for subjects
          class Subject < self

            FORMAT = '(%02d/%02d) %3d%% - killtime: %0.02fs runtime: %0.02fs overhead: %0.02fs'.freeze

            delegate(
              :subject,
              :coverage_percent,
              :runtime,
              :amount_mutations_killed,
              :amount_mutations,
              :amount_mutation_results,
              :worktime,
              :overhead
            )

            # Run printer
            #
            # @return [self]
            #
            # @api private
            #
            def run
              puts("#{subject.identification} mutations: #{amount_mutations}")
              print_tests
              print_mutation_results
              print_progress_bar_finish
              print_stats
              self
            end

          private

            # Print stats
            #
            # @return [undefined]
            #
            # @api private
            #
            def print_stats
              status(
                FORMAT,
                amount_mutations_killed,
                amount_mutations,
                coverage_percent,
                worktime,
                runtime,
                overhead
              )
            end

            # Print tests
            #
            # @return [undefined]
            #
            # @api private
            #
            def print_tests
              puts(object.class)
            end

            # Print progress bar finish
            #
            # @return [undefined]
            #
            # @api private
            #
            def print_progress_bar_finish
              puts(NL) unless amount_mutation_results.zero?
            end

            # Print mutation results
            #
            # @return [undefined]
            #
            # @api private
            #
            def print_mutation_results
              visit_collection(Mutation, object.mutation_results)
            end

          end # SubjectProgress
        end # Progress
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
