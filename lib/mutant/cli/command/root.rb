# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class Root < self
        SUBCOMMANDS       = [Run, Subscription].freeze
        SHORT_DESCRIPTION = 'mutation testing engine main command'
        NAME              = 'mutant'
      end
    end # Command
  end # CLI
end # Mutant
