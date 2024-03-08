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
              visit_collection(Result, object.failed_test_results)
              visit(Env, object.env)
              FORMATS.each do |report, format, value|
                __send__(report, format, __send__(value))
              end
            end

          private

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

          # Reporter for progressive output format on scheduler Status objects
          class StatusProgressive < self
            FORMAT = 'progress: %02d/%02d failed: %d runtime: %0.02fs testtime: %0.02fs tests/s: %0.02f'

            delegate(
              :amount_test_results,
              :amount_tests,
              :amount_tests_failed,
              :testtime,
              :runtime
            )

            # Run printer
            #
            # @return [undefined]
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

          private

            def object
              super().payload
            end

            def tests_per_second
              amount_test_results / runtime
            end
          end # StatusProgressive
        end # Test
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
