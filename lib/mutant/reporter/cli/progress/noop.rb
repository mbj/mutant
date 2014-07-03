module Mutant
  class Reporter
    class CLI
      class Progress
        # Noop CLI progress reporter
        class Noop < self

          handle(Mutant::Test)
          handle(Mutant::Mutation)
          handle(Mutant::Result::Env)
          handle(Mutant::Result::Test)

          # Noop progress report
          #
          # @return [self]
          #
          # @api private
          #
          def run
            self
          end

        end # Noop
      end # Progress
    end # CLI
  end # Reporter
end # Mutant
