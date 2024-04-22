# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class Environment
        class Run < self
          NAME              = 'run'
          SHORT_DESCRIPTION = 'Run code analysis'
          SUBCOMMANDS       = EMPTY_ARRAY

          NO_TESTS_MESSAGE = <<~'MESSAGE'
            ===============
            Mutant found no tests available for mutation testing.
            Mutation testing cannot be started.

            This can have various reasons:

            * You did not setup an integration, see:
              https://github.com/mbj/mutant/blob/main/docs/configuration.md#integration
            * You set environment variables like RSPEC_OPTS that filter out all tests.
            * You set configuration optiosn like `config.filter_run :focus` which do
              make rspec to not report any test.
            ===============
          MESSAGE

        private

          def action
            bootstrap
              .bind(&method(:verify_usage))
              .bind(&method(:validate_tests))
              .bind(&Mutation::Runner.public_method(:call))
              .bind(&method(:from_result))
          end

          def validate_tests(environment)
            if environment.integration.available_tests.empty?
              Either::Left.new(NO_TESTS_MESSAGE)
            else
              Either::Right.new(environment)
            end
          end

          def from_result(result)
            if result.success?
              Either::Right.new(nil)
            else
              Either::Left.new('Uncovered mutations detected, exiting nonzero!')
            end
          end

          def verify_usage(environment)
            environment.config.usage.verify.fmap { environment }
          end
        end # Run
      end # Environment
    end # Command
  end # CLI
end # Mutant
