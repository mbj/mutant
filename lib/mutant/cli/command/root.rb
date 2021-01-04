# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class Environment < self
        SUBCOMMANDS = [Environment::Subject, Environment::Show, Environment::Test].freeze
      end # Environment

      class Root < self
        NAME              = 'mutant'
        SHORT_DESCRIPTION = 'mutation testing engine main command'
        SUBCOMMANDS       = [Environment::Run, Environment, Subscription].freeze
      end # Root
    end # Command
  end # CLI
end # Mutant
