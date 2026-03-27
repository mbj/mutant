# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        # Subject result printer
        #
        # Renders subject identification, tests, and all uncovered mutations
        # inline so that subject context (source, node) is available when
        # printing mutation details.
        class SubjectResult < self

          delegate :uncovered_results, :tests

          MAP = {
            'evil'    => :evil_details,
            'neutral' => :neutral_details,
            'noop'    => :noop_details
          }.freeze

          NEUTRAL_MESSAGE = <<~'MESSAGE'
            --- Neutral failure ---
            Original code was inserted unmutated. And the test did NOT PASS.
            Your tests do not pass initially or you found a bug in mutant / unparser.
            Subject AST:
            %s
            Unparsed Source:
            %s
          MESSAGE

          NO_DIFF_MESSAGE = <<~'MESSAGE'
            --- Internal failure ---
            BUG: A generated mutation did not result in exactly one diff hunk!
            This is an invariant violation by the mutation generation engine.
            Please report a reproduction to https://github.com/mbj/mutant
            Original unparsed source:
            %s
            Original AST:
            %s
            Mutated unparsed source:
            %s
            Mutated AST:
            %s
          MESSAGE

          NOOP_MESSAGE = <<~'MESSAGE'
            ---- Noop failure -----
            No code was inserted. And the test did NOT PASS.
            This is typically a problem of your specs not passing unmutated.
          MESSAGE

          SEPARATOR    = '-----------------------'
          STATS_FORMAT = 'tests: %d, runtime: %.2fs, killtime: %.2fs'

          private_constant(*constants(false))

          # Run report printer
          #
          # @return [undefined]
          def run
            status(object.identification)
            puts(STATS_FORMAT % [tests.length, object.runtime, object.killtime])
            uncovered_results.each do |coverage_result|
              print_mutation_result(coverage_result.mutation_result)
            end
            print_selected_tests
          end

        private

          def print_selected_tests
            if tests.empty?
              puts('no selected tests')
            else
              puts("selected tests (#{tests.length}):")
              tests.each do |test|
                puts("- #{test.identification}")
              end
            end
          end

          def print_mutation_result(mutation_result)
            puts(mutation_result.mutation_identification)
            puts(SEPARATOR)
            visit(IsolationResult, mutation_result.isolation_result) if show_isolation_logs?(mutation_result)
            __send__(MAP.fetch(mutation_result.mutation_type), mutation_result)
            puts(SEPARATOR)
          end

          def show_isolation_logs?(mutation_result)
            display_config.isolation_logs || !mutation_result.mutation_type.eql?('evil')
          end

          # rubocop:disable Metrics/MethodLength
          def evil_details(mutation_result)
            diff = mutation_result.mutation_diff

            if diff
              output.write(color? ? colorize_diff(diff) : diff)
            else
              info(
                NO_DIFF_MESSAGE,
                object.source,
                object.node.inspect,
                mutation_result.mutation_source,
                mutation_result.mutation_node.inspect
              )
            end
          end
          # rubocop:enable Metrics/MethodLength

          def noop_details(_mutation_result)
            info(NOOP_MESSAGE)
          end

          def neutral_details(mutation_result)
            info(NEUTRAL_MESSAGE, object.node.inspect, mutation_result.mutation_source)
          end

        end # SubjectResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
