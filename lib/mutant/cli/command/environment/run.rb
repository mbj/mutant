# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class Environment
        class Run < self
          NAME              = 'run'
          SHORT_DESCRIPTION = 'Run code analysis'
          SUBCOMMANDS       = EMPTY_ARRAY

          UNLICENSED = <<~MESSAGE.lines.freeze
            You are using mutant unlicensed.

            See https://github.com/mbj/mutant#licensing to aquire a license.
            Note: Its free for opensource use, which is recommended for trials.
          MESSAGE

          NO_TESTS_MESSAGE = <<~'MESSAGE'
            ===============
            Mutant found no tests. Mutation testing cannot be started.

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
            License.call(world)
              .bind { bootstrap }
              .bind(&method(:validate_tests))
              .bind(&Runner.public_method(:call))
              .bind(&method(:from_result))
          end

          def validate_tests(environment)
            if environment.integration.all_tests.length.zero?
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
        end # Run
      end # Environment
    end # Command
  end # CLI
end # Mutant
