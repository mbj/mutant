module Mutant
  class Reporter
    class CLI
      # CLI output format
      class Format
        include AbstractType, Anima.new(:tty)

        # Return start representation
        #
        # @param [Env] env
        #
        # @return [String]
        #
        # @api private
        #
        abstract_method :start

        # Return progress representation
        #
        # @param [Runner::Collector] collector
        #
        # @return [String]
        #
        # @api private
        #
        abstract_method :progress

        # Format result
        #
        # @param [Result::Env] env
        #
        # @return [String]
        #
        # @api private
        #
        def report(env)
          format(Printer::EnvResult, env)
        end

        # Output abstraction to decouple tty? from buffer
        class Output
          include Concord.new(:tty, :buffer)

          # Test if output is a tty
          #
          # @return [Boolean]
          #
          # @api private
          #
          def tty?
            @tty
          end

          [:puts, :write].each do |name|
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
        #
        def format(printer, object)
          buffer = new_buffer
          printer.run(Output.new(tty, buffer), object)
          buffer.rewind
          buffer.read
        end

        # Format for progressive non rewindable output
        class Progressive < self

          # Return start representation
          #
          # @return [String]
          #
          # @api private
          #
          def start(env)
            format(Printer::Config, env.config)
          end

          # Return progress representation
          #
          # @return [String]
          #
          # @api private
          #
          def progress(collector)
            format(Printer::MutationProgressResult, collector.last_mutation_result)
          end

        private

          # Return new buffer
          #
          # @return [StringIO]
          #
          # @api private
          #
          def new_buffer
            StringIO.new
          end

        end # Progressive

        # Format for framed rewindable output
        class Framed < self
          include anima.add(:tput)

          BUFFER_FLAGS = 'a+'.freeze

          # Rate per second progress report fires
          OUTPUT_RATE = 1.0 / 20

          # Initialize object
          #
          # @return [undefined]
          #
          # @api private
          #
          def initialize(*)
            super
            @last_frame = nil
          end

          # Format start
          #
          # @param [Env] env
          #
          # @return [String]
          #
          # @api private
          #
          def start(_env)
            tput.prepare
          end

          # Format progress
          #
          # @param [Runner::Collector] collector
          #
          # @return [String]
          #
          # @api private
          #
          def progress(collector)
            throttle do
              format(Printer::Collector, collector)
            end.to_s
          end

        private

          # Return new buffer
          #
          # @return [StringIO]
          #
          # @api private
          #
          def new_buffer
            # For some reason this raises an Ernno::EACCESS errror:
            #
            #  StringIO.new(Tput::INSTANCE.restore, BUFFER_FLAGS)
            #
            buffer = StringIO.new
            buffer << tput.restore
          end

          # Call block throttled
          #
          # @return [self]
          #
          # @api private
          #
          def throttle
            now = Time.now
            return if @last_frame && (now - @last_frame) < OUTPUT_RATE
            yield.tap { @last_frame = now }
          end

        end # Framed
      end # Format
    end # CLI
  end # Reporter
end # Mutant
