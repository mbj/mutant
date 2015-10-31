module Mutant
  class Reporter
    class CLI
      # CLI output format
      class Format
        include AbstractType, Anima.new(:tty)

        # Start representation
        #
        # @param [Env] env
        #
        # @return [String]
        #
        # @api private
        abstract_method :start

        # Progress representation
        #
        # @param [Runner::Status] status
        #
        # @return [String]
        #
        # @api private
        abstract_method :progress

        # Report delay in seconds
        #
        # @return [Float]
        #
        # @api private
        def delay
          self.class::REPORT_DELAY
        end

        # Output abstraction to decouple tty? from buffer
        class Output
          include Concord.new(:tty, :buffer)

          # Test if output is a tty
          #
          # @return [Boolean]
          #
          # @api private
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
        #
        # @api private
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
          #
          # @api private
          def start(env)
            format(Printer::Config, env.config)
          end

          # Progress representation
          #
          # @return [String]
          #
          # @api private
          def progress(status)
            format(Printer::StatusProgressive, status)
          end

        private

          # New buffer
          #
          # @return [StringIO]
          #
          # @api private
          def new_buffer
            StringIO.new
          end

        end # Progressive

        # Format for framed rewindable output
        class Framed < self
          include anima.add(:tput)

          BUFFER_FLAGS = 'a+'.freeze

          REPORT_FREQUENCY = 20.0
          REPORT_DELAY     = 1 / REPORT_FREQUENCY

          # Format start
          #
          # @param [Env] env
          #
          # @return [String]
          #
          # @api private
          def start(_env)
            tput.prepare
          end

          # Format progress
          #
          # @param [Runner::Status] status
          #
          # @return [String]
          #
          # @api private
          def progress(status)
            format(Printer::Status, status)
          end

        private

          # New buffer
          #
          # @return [StringIO]
          #
          # @api private
          def new_buffer
            # For some reason this raises an Ernno::EACCESS errror:
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
