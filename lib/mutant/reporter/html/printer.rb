# encoding: utf-8

module Mutant
  class Reporter
    class HTML

      # CLI runner status printer base class
      class Printer
        include AbstractType, Delegator, Adamantium::Flat, Concord.new(:output, :object)

        # Run printer on object to output
        #
        # @param [IO] output
        # @param [Object] object
        #
        # @return [self]
        #
        def self.run(output, object)
          handler = lookup(object.class)
          handler.new(output, object).run
          self
        end

        # Run printer
        #
        # @return [self]
        #
        # @api private
        #
        abstract_method :run

      private

        # Visit object
        #
        # @param [Object] object
        #
        # @return [undefined]
        #
        # @api private
        #
        def visit(object)
          self.class.run(output, object)
        end

        # Print a line to output
        #
        # @return [undefined]
        #
        # @api private
        #
        def puts(string = NL)
          output.puts(string)
        end

      end # Printer
    end # HTML
  end # Reporter
end # Mutant
