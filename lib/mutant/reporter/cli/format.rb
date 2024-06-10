# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      # CLI output format
      #
      # rubocop:disable Style/FormatString
      class Format
        include AbstractType, Anima.new(:tty)

        # Start representation
        #
        # @param [Env] env
        #
        # @return [String]
        abstract_method :start

        # Progress representation
        #
        # @return [String]
        abstract_method :progress

        # Progress representation
        #
        # @return [String]
        abstract_method :test_progress

        # Report delay in seconds
        #
        # @return [Float]
        def delay
          self.class::REPORT_DELAY
        end

        # Output abstraction to decouple tty? from buffer
        class Output
          include Anima.new(:tty, :buffer)

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
          printer.call(output: Output.new(tty:, buffer:), object:)
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

          # Test start representation
          #
          # @return [String]
          def test_start(env)
            format(Printer::Test::Env, env)
          end

          # Progress representation
          #
          # @return [String]
          def progress(status)
            format(Printer::StatusProgressive, status)
          end

          # Progress representation
          #
          # @return [String]
          def test_progress(status)
            format(Printer::Test::StatusProgressive, status)
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
