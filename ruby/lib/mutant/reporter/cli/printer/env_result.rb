# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        # Full env result reporter
        class EnvResult < self
          delegate(:failed_subject_results)

          SEPARATOR    = '-----------------------'
          MORE_MESSAGE = '(%d more alive mutation(s), use `mutant session subject %s` to see all details)'
          STATS_FORMAT = 'tests: %d, runtime: %.2fs, killtime: %.2fs'

          private_constant(*constants(false))

          # Run printer
          #
          # @return [undefined]
          def run
            unless failed_subject_results.empty?
              puts(AliveResults::ALIVE_EXPLANATION)
              failed_subject_results.each(&method(:print_subject_summary))
            end
            visit(EnvProgress, object)
          end

        private

          def print_subject_summary(subject_result)
            uncovered = subject_result.uncovered_results

            if uncovered.any? { |coverage_result| critical?(coverage_result.mutation_result) }
              SubjectResult.call(output:, object: subject_result)
              return
            end

            print_subject_line(subject_result)
            print_mutation_diff(uncovered.first.mutation_result)

            remaining = uncovered.length - 1

            return unless remaining.positive?

            puts(MORE_MESSAGE % [remaining, subject_result.expression_syntax])
          end

          def print_subject_line(subject_result)
            status(subject_result.identification)
            puts(STATS_FORMAT % [subject_result.tests.length, subject_result.runtime, subject_result.killtime])
          end

          def critical?(mutation_result)
            !mutation_result.mutation_type.eql?('evil')
          end

          def print_mutation_diff(mutation_result)
            puts(mutation_result.mutation_identification)
            puts(SEPARATOR)
            diff = mutation_result.mutation_diff
            output.write(color? ? colorize_diff(diff) : diff)
            puts(SEPARATOR)
          end
        end # EnvResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
