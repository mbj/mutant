# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      # CLI runner status printer base class
      class Printer
        # Printer display options
        class DisplayConfig
          include Anima.new(:isolation_logs)

          DEFAULT = new(isolation_logs: false)
          VERBOSE = new(isolation_logs: true)
        end

        include(
          AbstractType,
          Adamantium,
          Anima.new(:display_config, :output, :object),
          Procto
        )

        def self.call(output:, object:, display_config: DisplayConfig::DEFAULT)
          super
        end

        private_class_method :new

        def call = run

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

        def status_color = success? ? Unparser::Color::GREEN : Unparser::Color::RED

        def visit_collection(printer, collection)
          collection.each do |object|
            visit(printer, object)
          end
        end

        def visit(printer, object)
          printer.call(output:, object:)
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

        def colorize_diff(raw_diff)
          raw_diff.lines.map do |line|
            case line[0]
            when '+' then Unparser::Color::GREEN.format(line)
            when '-' then Unparser::Color::RED.format(line)
            else
              line
            end
          end.join
        end
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
