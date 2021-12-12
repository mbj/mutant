# frozen_string_literal: true

module Mutant
  class Reporter
    class Json
      # CLI output format
      #
      # rubocop:disable Style/FormatString
      class Format
        include AbstractType, Concord.new(:tty)

        # Start representation
        #
        # @param [Env] env
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
            format(Printer::Env, env)
          end

          # Progress representation
          #
          # @return [String]
          def progress(status)
            format(Printer::StatusProgressive, status)
          end

        private

          def new_buffer
            StringIO.new
          end

        end # Progressive
      end # Format
    end # CLI
  end # Reporter
end # Mutant
