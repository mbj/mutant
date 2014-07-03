module Mutant
  class Reporter
    class CLI
      # Abstract base and namespace class for process printers
      class Progress < Printer
        include AbstractType, Registry.new
      end # Progress
    end # CLI
  end # Reporter
end # Mutant
