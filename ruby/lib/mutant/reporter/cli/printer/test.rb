# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        class Test < self
          # Printer for test config
          class Config < self

            # Report configuration
            #
            # @param [Mutant::Config] config
            #
            # @return [undefined]
            #
            def run
              info('Fail-Fast:    %s', object.fail_fast)
              info('Integration:  %s', object.integration.name || 'null')
              info('Jobs:         %s', object.jobs || 'auto')
            end
          end # Config

          # Env printer
          class Env < self
            delegate(
              :amount_available_tests,
              :amount_selected_tests,
              :amount_all_tests,
              :config
            )

            FORMATS = [
            ].each(&:freeze)

            # Run printer
            #
            # @return [undefined]
            def run
              info('Test environment:')
              visit(Config, config)
              info('Tests:        %s', amount_all_tests)
            end
          end # Env

          # Full env result reporter
          class EnvResult < self
            delegate(
              :amount_test_results,
              :amount_tests_failed,
              :amount_tests_success,
              :runtime,
              :testtime
            )

            FORMATS = [
              [:info,   'Test-Results: %0d',     :amount_test_results    ],
              [:info,   'Test-Failed:  %0d',     :amount_tests_failed    ],
              [:info,   'Test-Success: %0d',     :amount_tests_success   ],
              [:info,   'Runtime:      %0.2fs',  :runtime                ],
              [:info,   'Testtime:     %0.2fs',  :testtime               ],
              [:info,   'Efficiency:   %0.2f%%', :efficiency_percent     ]
            ].each(&:freeze)

            private_constant(*constants(false))

            # Run printer
            #
            # @return [undefined]
            def run
              visit_failed
              visit(Env, object.env)
              FORMATS.each do |report, format, value|
                __send__(report, format, __send__(value))
              end
            end

          private

            def visit_failed
              failed = object.failed_test_results

              if object.env.config.fail_fast
                visit_failed_tests(failed.take(1))
                visit_other_failed(failed.drop(1))
              else
                visit_failed_tests(failed)
              end
            end

            def visit_other_failed(other)
              return if other.empty?

              puts('Other failed tests (report suppressed from fail fast): %d' % other.length)
            end

            def visit_failed_tests(failed)
              visit_collection(Result, failed)
            end

            def efficiency_percent
              (testtime / runtime) * 100
            end
          end # EnvResult

          # Reporter for test results
          class Result < self

            # Run report printer
            #
            # @return [undefined]
            def run
              puts(object.output)
            end

          end # Result

          # Base class for progressive test status output
          class StatusProgressive < self
            delegate(
              :amount_test_results,
              :amount_tests,
              :amount_tests_failed,
              :testtime,
              :runtime
            )

          private

            def object
              super.payload
            end

            def tests_per_second
              amount_test_results / runtime
            end

            # Pipe output format (non-TTY)
            class Pipe < StatusProgressive
              FORMAT = 'progress: %02d/%02d failed: %d runtime: %0.02fs testtime: %0.02fs tests/s: %0.02f'

              def run
                status(
                  FORMAT,
                  amount_test_results,
                  amount_tests,
                  amount_tests_failed,
                  runtime,
                  testtime,
                  tests_per_second
                )
              end
            end # Pipe

            # TTY output format with progress bar
            class Tty < StatusProgressive
              FORMAT              = '%s %d/%d (%5.1f%%) %s failed: %d %0.1fs %0.2f/s'
              MIN_BAR_WIDTH       = 10
              MAX_BAR_WIDTH       = 40
              PREFIX              = 'TESTING'
              PERCENTAGE_ESTIMATE = 99.9

              def run
                bar  = ProgressBar.build(current: amount_test_results, total: amount_tests, width: bar_width)
                line = FORMAT % format_args(bar.percentage, bar.render)
                output.write(colorize(status_color, line))
              end

            private

              def format_args(percentage, bar)
                [PREFIX, amount_test_results, amount_tests, percentage, bar,
                 amount_tests_failed, runtime, tests_per_second]
              end

              def bar_width
                non_bar_content = FORMAT % format_args(PERCENTAGE_ESTIMATE, nil)
                available_width = output.terminal_width - non_bar_content.length

                available_width.clamp(MIN_BAR_WIDTH, MAX_BAR_WIDTH)
              end
            end # Tty
          end # StatusProgressive
        end # Test
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
