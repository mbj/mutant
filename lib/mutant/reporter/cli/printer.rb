# encoding: utf-8

module Mutant
  class Reporter
    class CLI

      # CLI runner status printer base class
      class Printer
        include AbstractType, Adamantium::Flat, Concord.new(:object, :output)

        REGISTRY = {}

        # Create delegators to object
        #
        # @return [undefined]
        #
        # @api private
        #
        def self.delegate(*names)
          names.each do |name|
            define_delegator(name)
          end
        end
        private_class_method :delegate

        # Create delegator to object
        #
        # @param [Symbol] name
        #
        # @return [undefined]
        #
        # @api private
        #
        def self.define_delegator(name)
          define_method(name) do
            object.public_send(name)
          end
          private name
        end
        private_class_method :define_delegator

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
          printer = lookup(object.class)
          printer.run(object, output)
        end

        # Lookup printer class
        #
        # @param [Class] klass
        #
        # @return [Class:Printer]
        #   if found
        #
        # @raise [RuntimeError]
        #   otherwise
        #
        # @api private
        #
        def self.lookup(klass)
          current = klass
          until current == Object
            if REGISTRY.key?(current)
              return REGISTRY.fetch(current)
            end
            current = current.superclass
          end
          raise "No printer for: #{klass}"
        end
        private_class_method :lookup

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
