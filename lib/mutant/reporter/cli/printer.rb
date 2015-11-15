module Mutant
  class Reporter
    class CLI
      # CLI runner status printer base class
      class Printer
        include AbstractType, Adamantium::Flat, Concord.new(:output, :object), Procto.call(:run)

        private_class_method :new

        # Create delegators to object
        #
        # @return [undefined]
        #
        # @api private
        def self.delegate(*names)
          names.each(&method(:define_delegator))
        end
        private_class_method :delegate

        # Create delegator to object
        #
        # @param [Symbol] name
        #
        # @return [undefined]
        #
        # @api private
        def self.define_delegator(name)
          fail "method #{name} already defined" if instance_methods.include?(name)
          define_method(name) do
            object.public_send(name)
          end
          private name
        end
        private_class_method :define_delegator

        delegate :success?

        NL = "\n".freeze

        # Run printer
        #
        # @return [self]
        #
        # @api private
        abstract_method :run

      private

        # Status color
        #
        # @return [Color]
        #
        # @api private
        def status_color
          success? ? Color::GREEN : Color::RED
        end

        # Visit a collection of objects
        #
        # @return [Class::Printer] printer
        # @return [Enumerable<Object>] collection
        #
        # @return [undefined]
        #
        # @api private
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
        #
        # @api private
        def visit(printer, object)
          printer.call(output, object)
        end

        # Print an info line to output
        #
        # @return [undefined]
        #
        # @api private
        def info(string, *arguments)
          puts(format(string, *arguments))
        end

        # Print a status line to output
        #
        # @return [undefined]
        #
        # @api private
        def status(string, *arguments)
          puts(colorize(status_color, format(string, *arguments)))
        end

        # Print a line to output
        #
        # @return [undefined]
        #
        # @api private
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
        #
        # @api private
        def colorize(color, message)
          color = Color::NONE unless tty?
          color.format(message)
        end

        # Test if output is a tty
        #
        # @return [Boolean]
        #
        # @api private
        def tty?
          output.tty?
        end

        # Test if output can be colored
        #
        # @return [Boolean]
        #
        # @api private
        alias_method :color?, :tty?
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
