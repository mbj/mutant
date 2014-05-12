module Mutant
  class Reporter
    class CLI
      class Progress
        class Noop < self

          handle(Mutant::Mutation)

          # Noop progress report
          #
          # @return [self]
          #
          def run
            self
          end

        end # Noop
      end # Progress
    end # CLI
  end # Reporter
end # Mutant
