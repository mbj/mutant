# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class Environment
        class Test < self
          NAME              = 'test'
          SHORT_DESCRIPTION = 'test subcommands'

        private

          def parse_remaining_arguments(arguments)
            arguments.each(&method(:add_integration_argument))
            Either::Right.new(self)
          end

          def bootstrap
            env = Env.empty(world, @config)

            env
              .record(:config) { Config.load(cli_config: @config, world:) }
              .bind { |config| Bootstrap.call_test(env.with(config:)) }
          end

          class List < self
            NAME              = 'list'
            SHORT_DESCRIPTION = 'List tests detected in the environment'
            SUBCOMMANDS       = EMPTY_ARRAY

          private

            def action
              bootstrap.fmap(&method(:list_tests))
            end

            def list_tests(env)
              tests = env.integration.all_tests
              print('All tests in environment: %d' % tests.length)
              tests.each do |test|
                print(test.identification)
              end
            end
          end

          class Run < self
            NAME              = 'run'
            SHORT_DESCRIPTION = 'Run tests'
            SUBCOMMANDS       = EMPTY_ARRAY

          private

            def action
              bootstrap
                .bind(&Mutant::Test::Runner.public_method(:call))
                .bind(&method(:from_result))
            end

            def from_result(result)
              if result.success?
                Either::Right.new(nil)
              else
                Either::Left.new('Test failures, exiting nonzero!')
              end
            end

            # Alias to root mount
            class Root < self
              NAME        = 'test'
              SUBCOMMANDS = EMPTY_ARRAY
            end
          end

          SUBCOMMANDS = [List, Run].freeze
        end # Test
      end # Environment
    end # Command
  end # CLI
end # Mutant
