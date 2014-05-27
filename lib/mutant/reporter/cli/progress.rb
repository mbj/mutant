# encoding: utf-8

module Mutant
  class Reporter
    class CLI
      # Abstract base class for process printers
      class Progress < Printer
        include AbstractType, Registry.new

        delegate :running?
      end # Progress
    end # CLI
  end # Reporter
end # Mutant
