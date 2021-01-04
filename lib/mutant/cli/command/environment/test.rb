# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class Environment
        class Test < self
          NAME              = 'test'
          SHORT_DESCRIPTION = 'test subcommands'

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
              print('Tests in environment: %d' % tests.length)
              tests.each do |test|
                print(test.identification)
              end
            end
          end

          SUBCOMMANDS = [List].freeze
        end # Test
      end # Environment
    end # Command
  end # CLI
end # Mutant
