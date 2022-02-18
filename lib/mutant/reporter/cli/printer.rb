# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      # CLI runner status printer base class
      class Printer
        include(
          AbstractType,
          Adamantium,
          Concord.new(:output, :object, :env),
          Procto
        )

        private_class_method :new

        def call
          run
        end

        # Create delegators to object
        #
        # @return [undefined]
        def self.delegate(*names)
          names.each(&method(:define_delegator))
        end
        private_class_method :delegate

        # Create delegator to object
        #
        # @param [Symbol] name
        #
        # @return [undefined]
        def self.define_delegator(name)
          define_method(name) do
            object.public_send(name)
          end
          private(name)
        end
        private_class_method :define_delegator

        delegate :success?

        NL = "\n"

        # Run printer
        #
        # @return [self]
        abstract_method :run

      private

        def status_color
          success? ? Unparser::Color::GREEN : Unparser::Color::RED
        end

        def visit_collection(printer, collection)
          collection.each do |object|
            visit(printer, object)
          end
        end

        def visit(printer, object)
          printer.call(output, object, env)
        end

        def info(string, *arguments)
          puts(string % arguments)
        end

        def status(string, *arguments)
          puts(colorize(status_color, string % arguments))
        end

        def puts(string)
          output.puts(string)
        end

        def colorize(color, message)
          color = Unparser::Color::NONE unless tty?
          color.format(message)
        end

        def tty?
          output.tty?
        end

        alias_method :color?, :tty?
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
