# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      # CLI output format
      #
      # rubocop:disable FormatString
      class Format
        include AbstractType, Anima.new(:tty)

        # Start representation
        #
        # @param [Env::Bootstrap] env
        #
        # @return [String]
        abstract_method :start

        # Progress representation
        #
        # @param [Runner::Status] status
        #
        # @return [String]
        abstract_method :progress

        # Report delay in seconds
        #
        # @return [Float]
        def delay
          self.class::REPORT_DELAY
        end

        # Output abstraction to decouple tty? from buffer
        class Output
          include Concord.new(:tty, :buffer)

          # Test if output is a tty
          #
          # @return [Boolean]
          alias_method :tty?, :tty
          public :tty?

          %i[puts write].each do |name|
            define_method(name) do |*args, &block|
              buffer.public_send(name, *args, &block)
            end
          end
        end # Output

      private

        # Format object with printer
        #
        # @param [Class:Printer] printer
        # @param [Object] object
        #
        # @return [String]
        def format(printer, object)
          buffer = new_buffer
          printer.call(Output.new(tty, buffer), object)
          buffer.rewind
          buffer.read
        end

        # Format for progressive non rewindable output
        class Progressive < self

          REPORT_FREQUENCY = 1.0
          REPORT_DELAY     = 1 / REPORT_FREQUENCY

          # Start representation
          #
          # @return [String]
          def start(env)
            format(Printer::Config, env.config)
          end

          # Progress representation
          #
          # @return [String]
          def progress(status)
            format(Printer::StatusProgressive, status)
          end

        private

          # New buffer
          #
          # @return [StringIO]
          def new_buffer
            StringIO.new
          end

        end # Progressive

        # Format for framed rewindable output
        class Framed < self
          include anima.add(:tput)

          BUFFER_FLAGS = 'a+'

          REPORT_FREQUENCY = 20.0
          REPORT_DELAY     = 1 / REPORT_FREQUENCY

          # Format start
          #
          # @param [Env::Bootstrap] env
          #
          # @return [String]
          def start(_env)
            tput.prepare
          end

          # Format progress
          #
          # @param [Runner::Status] status
          #
          # @return [String]
          def progress(status)
            format(Printer::Status, status)
          end

        private

          # New buffer
          #
          # @return [StringIO]
          def new_buffer
            # For some reason this raises an Errno::EACCESS error:
            #
            #  StringIO.new(Tput::INSTANCE.restore, BUFFER_FLAGS)
            #
            buffer = StringIO.new
            buffer << tput.restore
          end

        end # Framed
      end # Format
    end # CLI
  end # Reporter
end # Mutant
