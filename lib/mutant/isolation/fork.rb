# frozen_string_literal: true

module Mutant
  class Isolation
    # Isolation via the fork(2) systemcall.
    class Fork < self
      include(
        Adamantium::Flat,
        Anima.new(:devnull, :io, :marshal, :process, :stderr, :stdout)
      )

      ATTRIBUTES = (anima.attribute_names + %i[block result_pipe]).freeze

      # Unsucessful result as child exited nonzero
      class ChildError < Result
        include Concord::Public.new(:value)
      end # ChildError

      # Unsucessful result as fork failed
      class ForkError < Result
        include Equalizer.new
      end # ForkError

      # Pipe abstraction
      class Pipe
        include Adamantium::Flat, Anima.new(:reader, :writer)

        # Run block with pipe in binmode
        #
        # @return [undefined]
        def self.with(io)
          io.pipe(binmode: true) do |(reader, writer)|
            yield new(reader: reader, writer: writer)
          end
        end

        # Child writer end of the pipe
        #
        # @return [IO]
        def child
          reader.close
          writer
        end

        # Parent reader end of the pipe
        #
        # @return [IO]
        def parent
          writer.close
          reader
        end
      end # Pipe

      # ignore :reek:InstanceVariableAssumption
      class Parent
        include(
          Anima.new(*ATTRIBUTES),
          Procto.call
        )

        # Prevent mutation from `process.fork` to `fork` to call Kernel#fork
        undef_method :fork

        # Parent process
        #
        # @return [Result]
        def call
          pid = start_child or return ForkError.new

          read_child_result(pid)

          @result
        end

      private

        # Start child process
        #
        # @return [Integer]
        def start_child
          process.fork do
            Child.call(to_h.merge(result_pipe: result_pipe.child))
          end
        end

        # Read child result
        #
        # @param [Integer] pid
        #
        # @return [undefined]
        def read_child_result(pid)
          add_result(Result::Success.new(marshal.load(result_pipe.parent)))
        rescue ArgumentError, EOFError => exception
          add_result(Result::Exception.new(exception))
        ensure
          wait_child(pid)
        end

        # Wait for child process
        #
        # @param [Integer] pid
        #
        # @return [undefined]
        def wait_child(pid)
          _pid, status = process.wait2(pid)

          add_result(ChildError.new(status)) unless status.success?
        end

        # Add a result
        #
        # @param [Result]
        def add_result(result)
          @result = defined?(@result) ? @result.add_error(result) : result
        end
      end # Parent

      class Child
        include(
          Adamantium::Flat,
          Anima.new(*ATTRIBUTES),
          Procto.call
        )

        # Handle child process
        #
        # @return [undefined]
        def call
          result_pipe.syswrite(marshal.dump(compute(&block)))
          result_pipe.close
        end

      private

        # The block result computed under silencing
        #
        # @return [Object]
        def compute
          devnull.call do |null|
            stderr.reopen(null)
            stdout.reopen(null)
            yield
          end
        end
      end # Child

      private_constant(*(constants(false) - %i[ChildError ForkError]))

      # Call block in isolation
      #
      # @return [Result]
      #   execution result
      def call(&block)
        Pipe.with(io) do |result|
          Parent.call(to_h.merge(block: block, result_pipe: result))
        end
      end
    end # Fork
  end # Isolation
end # Mutant
