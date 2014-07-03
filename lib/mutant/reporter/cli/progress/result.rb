module Mutant
  class Reporter
    class CLI
      class Progress
        # Abstract namespace class for result progress printers
        class Result < self
          include AbstractType
        end # Result
      end # Progress
    end # CLI
  end # Reporter
end # Mutant
