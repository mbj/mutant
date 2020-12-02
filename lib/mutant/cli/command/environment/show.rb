# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class Environment
        class Show < self
          NAME              = 'show'
          SHORT_DESCRIPTION = 'Display environment without coverage analysis'
          SUBCOMMANDS       = EMPTY_ARRAY

        private

          def execute
            Config.load_config_file(world)
              .fmap(&method(:expand))
              .bind { Bootstrap.apply(world, @config) }
              .fmap(&method(:report_env))
              .right?
          end

          def report_env(env)
            env.config.reporter.start(env)
          end
        end # Show
      end # Environment
    end # Command
  end # CLI
end # Mutant
