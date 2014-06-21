# encoding: utf-8

module Mutant
  class Reporter
    class HTML
      # Abstract base class for process printers
      class Report < Printer
        include AbstractType, Registry.new
      end # Report
    end # CLI
  end # Reporter
end # Mutant
