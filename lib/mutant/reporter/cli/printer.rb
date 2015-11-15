module Mutant
  class Reporter
    class CLI
      # CLI runner status printer base class
      class Printer
        include AbstractType, Delegator, Adamantium::Flat, Concord.new(:output, :object), Procto.call(:run)

        private_class_method :new

        delegate :success?

        NL = "\n".freeze

        # Run printer
        #
        # @return [self]
        abstract_method :run

      private

        # Status color
        #
        # @return [Color]
        def status_color
          success? ? Color::GREEN : Color::RED
        end

        # Visit a collection of objects
        #
        # @return [Class::Printer] printer
        # @return [Enumerable<Object>] collection
        #
        # @return [undefined]
        def visit_collection(printer, collection)
          collection.each do |object|
            visit(printer, object)
          end
        end

        # Visit object
        #
        # @param [Class::Printer] printer
        # @param [Object] object
        #
        # @return [undefined]
        def visit(printer, object)
          printer.call(output, object)
        end

        # Print an info line to output
        #
        # @return [undefined]
        def info(string, *arguments)
          puts(format(string, *arguments))
        end

        # Print a status line to output
        #
        # @return [undefined]
        def status(string, *arguments)
          puts(colorize(status_color, format(string, *arguments)))
        end

        # Print a line to output
        #
        # @return [undefined]
        def puts(string)
          output.puts(string)
        end

        # Colorize message
        #
        # @param [Color] color
        # @param [String] message
        #
        # @return [String]
        #   if color is enabled
        #   unmodified message otherwise
        def colorize(color, message)
          color = Color::NONE unless tty?
          color.format(message)
        end

        # Test if output is a tty
        #
        # @return [Boolean]
        def tty?
          output.tty?
        end

        # Test if output can be colored
        #
        # @return [Boolean]
        alias_method :color?, :tty?
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
