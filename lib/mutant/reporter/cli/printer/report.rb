module Mutant
  class Reporter
    class CLI
      class Printer
        class Report < self

          # Report printer for configuration
          class Config < self

            # Report configuration
            #
            # @param [Mutant::Config] config
            #
            # @return [self]
            #
            # @api private
            #
            def run
              info 'Mutant configuration:'
              info 'Matcher:         %s',      object.matcher_config.inspect
              info 'Integration:     %s',      object.integration.name
              info 'Expect Coverage: %0.2f%%', object.expected_coverage.inspect
              info 'Jobs:            %d',      object.jobs
              info 'Includes:        %s',      object.includes.inspect
              info 'Requires:        %s',      object.requires.inspect
              self
            end
          end # Config

          # Env summary report printer
          class EnvStart < self

            delegate(
              :config,
              :subjects,
              :mutations
            )

            # Run printer
            #
            # @return [self]
            #
            # @api private
            #
            def run
              visit(Config, config)
              info 'Subjects:        %s', subjects.length
              info 'Tests:           %s', config.integration.all_tests.length
              info 'Mutations:       %s', mutations.length
              self
            end
          end # EnvStart

          # Env summary report printer
          class EnvSummary < self

            delegate(
              :amount_tests_tried,
              :amount_subjects,
              :amount_mutations,
              :amount_mutations_alive,
              :amount_mutations_killed,
              :runtime,
              :worktime,
              :overhead_percent,
              :coverage_percent,
              :env
            )

            # Run printer
            #
            # @return [self]
            #
            # @api private
            #
            def run
              visit(EnvStart, env)
              info 'Kills:           %s',        amount_mutations_killed
              info 'Alive:           %s',        amount_mutations_alive
              info 'Tests-Tried:     %s',        amount_tests_tried
              info 'Runtime:         %0.2fs',    runtime
              info 'Killtime:        %0.2fs',    worktime
              info 'Overhead:        %0.2f%%',   overhead_percent
              status 'Coverage:        %0.2f%%', coverage_percent
              status 'Expected:        %0.2f%%', env.config.expected_coverage
              self
            end

          end # Env

          # Full env result report printer
          class Kill < self

            delegate(:failed_subject_results)

            # Run printer
            #
            # @return [self]
            #
            # @api private
            #
            def run
              visit_collection(Subject, failed_subject_results)
              visit(EnvSummary, object)
              self
            end

          end # EnvResult

          class Trace < self

            delegate(:failed_test_traces)

            # Run printer
            #
            # @return [self]
            #
            def run
              print_status
              return if success?
              visit_collection(Test, failed_test_traces.map(&:test_result))
              status('Tracing failed with at least %d failed tests', failed_test_traces.length)
              print_status
            end

          private

            # Print status
            #
            # @return [undefined]
            #
            # @api private
            #
            def print_status
              status('Trace: %s', success? ? 'SUCCESS' : 'FAIL')
            end
          end # Trace

          # Printer subject result
          class Subject < self

            delegate :subject, :failed_mutations

            # Run report printer
            #
            # @return [self]
            #
            # @api private
            #
            def run
              status(subject.identification)
              visit_collection(Mutation, object.alive_mutation_results)
              self
            end

          end # SubjectResult

          # Printer for mutation results
          class Mutation < self

            delegate :mutation, :test_result, :tests

            DIFF_ERROR_MESSAGE = 'BUG: Mutation NOT resulted in exactly one diff hunk. Please report a reproduction!'.freeze

            MAP = {
              Mutant::Mutation::Evil    => :evil_details,
              Mutant::Mutation::Neutral => :neutral_details,
              Mutant::Mutation::Noop    => :noop_details
            }.freeze

            NEUTRAL_MESSAGE =
              "--- Neutral failure ---\n" \
              "Original code was inserted unmutated. And the test did NOT PASS.\n" \
              "Your tests do not pass initially or you found a bug in mutant / unparser.\n" \
              "Subject AST:\n" \
              "%s\n" \
              "Unparsed Source:\n" \
              "%s\n" \
              "Test Result:\n".freeze

            NOOP_MESSAGE    =
              "---- Noop failure -----\n" \
              "No code was inserted. And the test did NOT PASS.\n" \
              "This is typically a problem of your specs not passing unmutated.\n" \
              "Test Result:\n".freeze

            FOOTER = '-----------------------'.freeze

            # Run report printer
            #
            # @return [self]
            #
            # @api private
            #
            def run
              puts(mutation.identification)
              print_details
              puts(FOOTER)
              self
            end

          private

            # Return details
            #
            # @return [undefined]
            #
            # @api private
            #
            def print_details
              send(MAP.fetch(mutation.class))
            end

            # Return evil details
            #
            # @return [String]
            #
            # @api private
            #
            def evil_details
              original, current = mutation.original_source, mutation.source
              diff = Mutant::Diff.build(original, current)
              diff = color? ? diff.colorized_diff : diff.diff
              puts(diff || ['Original source:', original, 'Mutated Source:', current, DIFF_ERROR_MESSAGE])
            end

            # Noop details
            #
            # @return [String]
            #
            # @api private
            #
            def noop_details
              info(NOOP_MESSAGE)
              visit_test_result
            end

            # Neutral details
            #
            # @return [String]
            #
            # @api private
            #
            def neutral_details
              info(NEUTRAL_MESSAGE, mutation.subject.node.inspect, mutation.source)
              visit_test_result
            end

            # Visit failed test results
            #
            # @return [undefined]
            #
            # @api private
            #
            def visit_test_result
              visit(Test, test_result)
            end

          end # MutationResult

          # Test result reporter
          class Test < self
            delegate :tests, :runtime

            # Run test result reporter
            #
            # @return [self]
            #
            # @api private
            #
            def run
              status('- %d @ runtime: %s', tests.length, runtime)
              tests.each do |test|
                puts("  - #{test.identification}")
              end
              puts('Test Output:')
              puts(object.output)
            end

            # Test if test result is successful
            #
            # Only used to determine color.
            #
            # @return [false]
            #
            # @api private
            #
            def success?
              false
            end

          end # TestResult
        end # Report
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
