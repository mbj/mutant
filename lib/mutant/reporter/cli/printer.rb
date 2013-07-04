module Mutant
  class Reporter
    class CLI

      # CLI runner status printer base class
      class Printer
        include AbstractType, Adamantium::Flat, Concord.new(:object, :output)

        REGISTRY = {}

        # Registre handler for class
        #
        # @param [Class] klass
        #
        # @return [undefined]
        #
        # @api private
        #
        def self.handle(klass)
          REGISTRY[klass] = self
        end

        # Finalize CLI reporter
        #
        # @return [undefined]
        #
        # @api private
        #
        def self.finalize
          REGISTRY.freeze
        end

        # Build printer
        #
        # @return [Printer]
        #
        # @api private
        #
        def self.build(*args)
          new(*args)
        end

        # Run printer
        #
        # @return [self]
        #
        # @api private
        #
        def self.run(*args)
          build(*args).run
          self
        end

        # Visit object
        #
        # @param [Object] object
        # @param [IO] output
        #
        # @return [undefined]
        #
        # @api private
        #
        def self.visit(object, output)
          printer = REGISTRY.fetch(object.class)
          printer.run(object, output)
        end

        abstract_method :run

      private

        # Return status color
        #
        # @return [Color]
        #
        # @api private
        #
        def color
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
          self.class.visit(object, output)
        end

        # Print an info line to output
        #
        # @return [undefined]
        #
        # @api private
        #
        def info(string, *arguments)
          puts(sprintf(string, *arguments))
        end

        # Print a status line to output
        #
        # @return [undefined]
        #
        # @api private
        #
        def status(string, *arguments)
          puts(colorize(color, sprintf(string, *arguments)))
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
        #   returns true if output is colored
        #
        # @return [false]
        #   returns false otherwise
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
        #   returns colorized string if color is enabled
        #   returns unmodified message otherwise
        #
        def colorize(color, message)
          color = Color::NONE unless tty?
          color.format(message)
        end

        # Test for output to tty
        #
        # @return [true]
        #   returns true if output is a tty
        #
        # @return [false]
        #   returns false otherwise
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
