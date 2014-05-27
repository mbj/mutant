# encoding: utf-8

module Mutant
  class Reporter
    class CLI

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

        # Return status color
        #
        # @return [Color]
        #
        # @api private
        #
        def status_color
          success? ? Color::GREEN : Color::RED
        end

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

        # Print an info line to output
        #
        # @return [undefined]
        #
        # @api private
        #
        def info(string, *arguments)
          puts(format(string, *arguments))
        end

        # Print a status line to output
        #
        # @return [undefined]
        #
        # @api private
        #
        def status(string, *arguments)
          puts(colorize(status_color, format(string, *arguments)))
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

        # Test if runner was successful
        #
        # @return [true]
        #   if runner is successful
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def success?
          object.success?
        end

        # Test for colored output
        #
        # @return [true]
        #   if output is colored
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def color?
          tty?
        end

        # Colorize message
        #
        # @param [Color] color
        # @param [String] message
        #
        # @api private
        #
        # @return [String]
        #   if color is enabled
        #   unmodified message otherwise
        #
        def colorize(color, message)
          color = Color::NONE unless tty?
          color.format(message)
        end

        # Test for output to tty
        #
        # @return [true]
        #   if output is a tty
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def tty?
          output.respond_to?(:tty?) && output.tty?
        end
        memoize :tty?

      end # Printer
    end # CLI
  end # Reporter
end # Mutant
