# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class Environment
        class IRB < self
          NAME              = 'irb'
          SHORT_DESCRIPTION = 'Run irb with mutant environment loaded'
          SUBCOMMANDS       = EMPTY_ARRAY

        private

          def action
            bootstrap.fmap { TOPLEVEL_BINDING.irb }
          end
        end # IRB
      end # Environment
    end # Command
  end # CLI
end # Mutant
