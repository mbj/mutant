# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class Environment < self
        SUBCOMMANDS = [Environment::Subject, Environment::Show, Environment::IRB, Environment::Test].freeze
      end # Environment

      class MCP < self
        SUBCOMMANDS = [MCP::Server, MCP::Info].freeze
      end # MCP

      class Root < self
        NAME              = 'mutant'
        SHORT_DESCRIPTION = 'mutation testing engine main command'
        SUBCOMMANDS       = [Environment::Run, Environment::Test::Run::Root, Environment, Util, MCP].freeze
      end # Root
    end # Command
  end # CLI
end # Mutant
